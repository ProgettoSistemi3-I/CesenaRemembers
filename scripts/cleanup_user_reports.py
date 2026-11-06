#!/usr/bin/env python3
"""Delete user reports older than the documented retention period.

Dry-run by default. Requires GOOGLE_APPLICATION_CREDENTIALS to point to a
Firebase service-account key stored outside the repository.
"""
from __future__ import annotations

import argparse
import calendar
import os
from datetime import datetime, timezone
from typing import Any

import firebase_admin
from firebase_admin import credentials, firestore


def subtract_months(value: datetime, months: int) -> datetime:
    month_index = value.month - 1 - months
    year = value.year + month_index // 12
    month = month_index % 12 + 1
    day = min(value.day, calendar.monthrange(year, month)[1])
    return value.replace(year=year, month=month, day=day)


def get_database() -> firestore.Client:
    if not firebase_admin._apps:
        if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
            raise RuntimeError(
                "Set GOOGLE_APPLICATION_CREDENTIALS to a service-account key "
                "stored outside the repository."
            )
        firebase_admin.initialize_app(
            credentials.ApplicationDefault()
        )
    return firestore.client()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Remove expired Cesena Remembers user reports."
    )
    parser.add_argument(
        "--older-than-months",
        type=int,
        default=24,
        help="Retention age in calendar months (default: 24).",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually delete reports. Without this flag, only show a dry-run.",
    )
    args = parser.parse_args()

    if args.older_than_months < 1 or args.older_than_months > 120:
        parser.error("--older-than-months must be between 1 and 120")

    cutoff = subtract_months(datetime.now(timezone.utc), args.older_than_months)
    db = get_database()
    query = (
        db.collection("user_reports")
        .where("createdAt", "<", cutoff)
        .order_by("createdAt")
    )

    deleted = 0
    batch = db.batch()
    batch_size = 0
    for report in query.stream():
        created_at: Any = (report.to_dict() or {}).get("createdAt")
        print(
            f"{'[DELETE]' if args.apply else '[DRY-RUN]'} "
            f"{report.id} createdAt={created_at}"
        )
        if not args.apply:
            continue

        batch.delete(report.reference)
        batch_size += 1
        deleted += 1
        if batch_size == 450:
            batch.commit()
            batch = db.batch()
            batch_size = 0

    if args.apply and batch_size:
        batch.commit()

    if args.apply:
        print(f"Deleted {deleted} expired report(s).")
    else:
        print("Dry-run only. Re-run with --apply to delete the listed reports.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
