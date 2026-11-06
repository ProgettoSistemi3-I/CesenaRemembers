#!/usr/bin/env python3
"""Purge or backfill expired Cesena Remembers moderation records.

Records in banned_users are retained for 24 calendar months from the ban date.
The script is dry-run by default. Legacy records without retentionUntil are
left untouched unless --backfill-legacy is selected.

Examples:
    python scripts/purge_expired_bans.py
    python scripts/purge_expired_bans.py --backfill-legacy
    python scripts/purge_expired_bans.py --backfill-legacy --apply
    python scripts/purge_expired_bans.py --apply
"""
from __future__ import annotations

import argparse
import calendar
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore


def add_months(value: datetime, months: int) -> datetime:
    month_index = value.month - 1 + months
    year = value.year + month_index // 12
    month = month_index % 12 + 1
    day = min(value.day, calendar.monthrange(year, month)[1])
    return value.replace(year=year, month=month, day=day)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-id", help="Firebase project ID")
    parser.add_argument(
        "--backfill-legacy",
        action="store_true",
        help="Assign a 24-month expiry to legacy records without retentionUntil",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write changes/delete expired records; otherwise only report them",
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
    backfill: list[tuple[firestore.DocumentReference, datetime]] = []
    for document in documents:
        data = document.to_dict() or {}
        retention_until = data.get("retentionUntil")
        if not isinstance(retention_until, datetime):
            if args.backfill_legacy:
                banned_at = data.get("bannedAt")
                if isinstance(banned_at, datetime):
                    if banned_at.tzinfo is None:
                        banned_at = banned_at.replace(tzinfo=timezone.utc)
                    expiry = add_months(banned_at, 24)
                else:
                    # Legacy records without a ban date start their documented
                    # retention window at backfill time instead of being deleted.
                    expiry = add_months(now, 24)
                backfill.append((document.reference, expiry))
            continue

        if retention_until.tzinfo is None:
            retention_until = retention_until.replace(tzinfo=timezone.utc)
        if retention_until <= now:
            expired.append(document.reference)

    print(f"Record di moderazione esaminati: {len(documents)}")
    print(f"Record con retention scaduta: {len(expired)}")
    print(f"Record legacy da backfill: {len(backfill)}")

    if not args.apply:
        print("[DRY-RUN] Nessuna modifica eseguita. Usa --apply per eseguire la pulizia.")
        return 0

    # Assign expiry first. Newly backfilled records are not considered expired
    # in this same run and can be purged only on a later scheduled run.
    for offset in range(0, len(backfill), 450):
        batch = db.batch()
        for reference, expiry in backfill[offset : offset + 450]:
            batch.set(reference, {"retentionUntil": expiry}, merge=True)
        batch.commit()

    for offset in range(0, len(expired), 450):
        batch = db.batch()
        for reference in expired[offset : offset + 450]:
            batch.delete(reference)
        batch.commit()

    print(f"Record con retention aggiornata: {len(backfill)}")
    print(f"Record eliminati: {len(expired)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
