#!/usr/bin/env python3
"""Crea la proiezione minima per la classifica globale (solo UID e XP).

Dry-run predefinito. Richiede GOOGLE_APPLICATION_CREDENTIALS con un service
account protetto fuori dal repository. Usare --apply per scrivere su Firestore.
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-id", help="ID progetto Firebase")
    parser.add_argument("--apply", action="store_true", help="scrive i documenti; senza flag esegue solo dry-run")
    args = parser.parse_args()

    key_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not key_path or not Path(key_path).is_file():
        print("Imposta GOOGLE_APPLICATION_CREDENTIALS su un service-account protetto.", file=sys.stderr)
        return 2

    cred = credentials.Certificate(key_path)
    options = {"projectId": args.project_id} if args.project_id else None
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred, options=options)
    db = firestore.client()

    users = list(db.collection("users").stream())
    banned = {doc.id for doc in db.collection("banned_users").stream()}
    rows: list[tuple[str, int]] = []
    for doc in users:
        data = doc.to_dict() or {}
        if doc.id in banned or data.get("profileCompleted") is not True:
            continue
        xp = data.get("xp", 0)
        if not isinstance(xp, int) or xp < 0:
            print(f"XP non valido per UID {doc.id}; interrotta senza scritture.", file=sys.stderr)
            return 3
        rows.append((doc.id, xp))

    existing = {doc.id for doc in db.collection("leaderboard").stream()}
    missing = [row for row in rows if row[0] not in existing]
    print(f"Profili completati non bannati: {len(rows)}")
    print(f"Documenti leaderboard già presenti: {len(existing)}")
    print(f"Documenti da creare/aggiornare: {len(rows)}; mancanti: {len(missing)}")
    print(f"Modalità: {'APPLY' if args.apply else 'DRY-RUN (nessuna scrittura)'}")

    if args.apply:
        for offset in range(0, len(rows), 400):
            batch = db.batch()
            for uid, xp in rows[offset:offset + 400]:
                batch.set(db.collection("leaderboard").document(uid), {"uid": uid, "xp": xp})
            batch.commit()
        print("Backfill classifica globale completato.")
    else:
        print("Nessuna scrittura eseguita. Ripeti con --apply dopo aver controllato il riepilogo.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
