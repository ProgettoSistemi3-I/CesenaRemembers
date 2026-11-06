#!/usr/bin/env python3
"""Purge expired Cesena Remembers moderation records.

Records in banned_users are retained for 24 calendar months from the ban date.
This script is dry-run by default; schedule --apply only after the policy has
been approved and the service account has been granted narrowly scoped access.

Examples:
    python scripts/purge_expired_bans.py
    python scripts/purge_expired_bans.py --apply
"""
from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-id", help="Firebase project ID")
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Delete expired records; without this flag only report them",
    )
    args = parser.parse_args()

    key_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not key_path or not Path(key_path).is_file():
        print(
            "Imposta GOOGLE_APPLICATION_CREDENTIALS su un service-account protetto.",
            file=sys.stderr,
        )
        return 2

    options = {"projectId": args.project_id} if args.project_id else None
    if not firebase_admin._apps:
        firebase_admin.initialize_app(credentials.Certificate(key_path), options=options)

    db = firestore.client()
    now = datetime.now(timezone.utc)
    documents = list(db.collection("banned_users").stream())

    expired = []
    missing_expiry = 0
    for document in documents:
        data = document.to_dict() or {}
        retention_until = data.get("retentionUntil")
        if not isinstance(retention_until, datetime):
            # Legacy records are not deleted until an expiry has been assigned.
            missing_expiry += 1
            continue
        if retention_until.tzinfo is None:
            retention_until = retention_until.replace(tzinfo=timezone.utc)
        if retention_until <= now:
            expired.append(document.reference)

    print(f"Record di moderazione esaminati: {len(documents)}")
    print(f"Record con retention scaduta: {len(expired)}")
    print(f"Record legacy senza retentionUntil (non eliminati): {missing_expiry}")

    if not args.apply:
        print("[DRY-RUN] Nessun documento eliminato. Usa --apply per eseguire la pulizia.")
        return 0

    # Firestore batches support up to 500 writes; stay below the hard limit.
    for offset in range(0, len(expired), 450):
        batch = db.batch()
        for reference in expired[offset : offset + 450]:
            batch.delete(reference)
        batch.commit()

    print(f"Record eliminati: {len(expired)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
