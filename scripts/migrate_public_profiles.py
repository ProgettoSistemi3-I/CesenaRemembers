#!/usr/bin/env python3
"""Migrate legacy users to the private/public Firestore schema used by the app.

Safe by default: prints a plan only. Pass --apply after taking a Firestore backup.
Use a Firebase Admin SDK service account kept outside the repository.
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from datetime import datetime
from typing import Any

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError as exc:
    raise SystemExit("Installa le dipendenze: python -m pip install firebase-admin") from exc

USERNAME = re.compile(r"^[a-z0-9_.]{3,20}$")
KNOWN_ACHIEVEMENTS = {
    "first_visit", "first_quiz", "first_tour", "quiz_15", "perfect_tour",
    "xp_500", "tour_under_1h", "tour_under_30m", "friend_1", "friend_5",
}
KNOWN_POIS = {
    "santa_cristina", "rocca", "san_rocco", "abbazia_monte", "osservanza",
    "palazzo_ridotto", "stazione", "arrigoni", "fantaguzzi", "rifugi_antiaerei",
}


def as_int(value: Any, default: int = 0, maximum: int = 1_000_000_000) -> int:
    try:
        if isinstance(value, bool):
            return default
        return max(0, min(int(value), maximum))
    except (TypeError, ValueError, OverflowError):
        return default


def string_list(value: Any, limit: int) -> list[str]:
    if not isinstance(value, list):
        return []
    return list(dict.fromkeys(x.strip() for x in value if isinstance(x, str) and x.strip()))[:limit]


def filtered_list(value: Any, limit: int, allowed: set[str]) -> list[str]:
    return [item for item in string_list(value, limit) if item in allowed]


def bool_or(value: Any, default: bool) -> bool:
    return value if isinstance(value, bool) else default


def valid_timestamp(value: Any) -> bool:
    return isinstance(value, datetime)


def build_private_profile(data: dict[str, Any]) -> dict[str, Any] | None:
    raw_username = data.get("username")
    if not isinstance(raw_username, str):
        return None
    username = raw_username.strip()
    username_normalized = username.lower()
    display_name = str(data.get("displayName") or "").strip()
    if not USERNAME.fullmatch(username_normalized) or not 2 <= len(display_name) <= 30:
        return None

    xp = as_int(data.get("xp"))
    max_tour_xp = min(as_int(data.get("maxSingleTourXp")), xp)
    avatar_id = str(data.get("avatarId") or "soldato").strip()[:40] or "soldato"
    raw_prefs = data.get("preferences")
    raw_prefs = raw_prefs if isinstance(raw_prefs, dict) else {}
    prefs = {
        "notifiche": bool_or(raw_prefs.get("notifiche"), True),
        "modalitaNotte": bool_or(raw_prefs.get("modalitaNotte"), False),
        "posizioneGps": bool_or(raw_prefs.get("posizioneGps"), True),
    }
    created_at = data.get("createdAt")

    private: dict[str, Any] = {
        "email": str(data.get("email") or "")[:254],
        "displayName": display_name,
        "displayNameNormalized": display_name.lower(),
        "username": username_normalized,
        "usernameNormalized": username_normalized,
        "avatarId": avatar_id,
        "profileCompleted": True,
        "onboardingCompleted": bool_or(data.get("onboardingCompleted"), False),
        "xp": xp,
        "leaderboardScore": xp,
        "visitedPoiIds": filtered_list(data.get("visitedPoiIds"), 200, KNOWN_POIS),
        "unlockedAchievements": filtered_list(data.get("unlockedAchievements"), 100, KNOWN_ACHIEVEMENTS),
        "pendingAchievements": filtered_list(data.get("pendingAchievements"), 100, KNOWN_ACHIEVEMENTS),
        "maxQuizScore": as_int(data.get("maxQuizScore"), maximum=100),
        "totalQuizCompleted": as_int(data.get("totalQuizCompleted")),
        "totalToursCompleted": as_int(data.get("totalToursCompleted")),
        "totalCorrectAnswers": as_int(data.get("totalCorrectAnswers")),
        "bestTourTimeSeconds": as_int(data.get("bestTourTimeSeconds")),
        "maxSingleTourXp": max_tour_xp,
        "friends": string_list(data.get("friends"), 500),
        "sentFriendRequests": string_list(data.get("sentFriendRequests"), 500),
        "receivedFriendRequests": string_list(data.get("receivedFriendRequests"), 500),
        "fcmTokens": string_list(data.get("fcmTokens"), 20),
        "preferences": prefs,
        "createdAt": created_at if valid_timestamp(created_at) else firestore.SERVER_TIMESTAMP,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }
    profile_completed_at = data.get("profileCompletedAt")
    if valid_timestamp(profile_completed_at):
        private["profileCompletedAt"] = profile_completed_at
    last_peer = data.get("lastFriendActionPeerUid")
    if isinstance(last_peer, str) and len(last_peer) <= 128:
        private["lastFriendActionPeerUid"] = last_peer
    return private


def build_public_profile(private: dict[str, Any]) -> dict[str, Any]:
    return {
        key: private[key]
        for key in (
            "displayName", "displayNameNormalized", "username", "usernameNormalized",
            "avatarId", "profileCompleted", "onboardingCompleted", "xp",
            "leaderboardScore", "visitedPoiIds", "unlockedAchievements", "maxQuizScore",
            "totalQuizCompleted", "totalToursCompleted", "totalCorrectAnswers",
            "bestTourTimeSeconds", "maxSingleTourXp", "friends",
        )
    }


def minimal_incomplete_profile(data: dict[str, Any]) -> dict[str, Any]:
    """Strip unfinished profiles to fields accepted by the onboarding Rules."""
    created_at = data.get("createdAt")
    return {
        "email": str(data.get("email") or "")[:254],
        "createdAt": created_at if valid_timestamp(created_at) else firestore.SERVER_TIMESTAMP,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-id", help="ID del progetto Firebase; default dalla credenziale")
    parser.add_argument("--apply", action="store_true", help="esegue le modifiche; senza questo flag è solo dry-run")
    args = parser.parse_args()
    key_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not key_path or not os.path.isfile(key_path):
        print("Imposta GOOGLE_APPLICATION_CREDENTIALS su un file service-account protetto e fuori dal repository.", file=sys.stderr)
        return 2
    cred = credentials.Certificate(key_path)
    options = {"projectId": args.project_id} if args.project_id else None
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred, options=options)
    db = firestore.client()

    source_users = list(db.collection("users").stream())
    migrated: dict[str, tuple[dict[str, Any], dict[str, Any]]] = {}
    incomplete: dict[str, dict[str, Any]] = {}
    skipped: list[str] = []
    username_owners: dict[str, str] = {}
    duplicate_usernames: list[tuple[str, str, str]] = []

    for doc in source_users:
        data = doc.to_dict() or {}
        if data.get("profileCompleted") is not True:
            incomplete[doc.id] = minimal_incomplete_profile(data)
            continue
        private = build_private_profile(data)
        if private is None:
            skipped.append(doc.id)
            continue
        uname = private["usernameNormalized"]
        other = username_owners.get(uname)
        if other is not None and other != doc.id:
            duplicate_usernames.append((uname, other, doc.id))
            skipped.extend([other, doc.id])
            migrated.pop(other, None)
            continue
        username_owners[uname] = doc.id
        migrated[doc.id] = (private, build_public_profile(private))

    # Do not write any data until every completed profile has a valid username/name
    # and all profile usernames are unique; otherwise an operator must fix it first.
    if skipped or duplicate_usernames:
        print(f"Utenti letti: {len(source_users)}; profili validi: {len(migrated)}; UID da correggere: {len(set(skipped))}")
        if skipped:
            print("UID da controllare manualmente:", ", ".join(sorted(set(skipped))[:50]))
        if duplicate_usernames:
            print("Username duplicati da risolvere prima della migrazione:")
            for username, uid_a, uid_b in duplicate_usernames[:30]:
                print(f"  {username}: {uid_a} / {uid_b}")
        print("Nessuna scrittura eseguita: correggi gli account segnalati e ripeti la modalità di prova.")
        return 3

    # Keep only mutual friendships, and convert only reciprocal one-way requests.
    raw_friends = {uid: set(profile[0]["friends"]) for uid, profile in migrated.items()}
    raw_sent = {uid: set(profile[0]["sentFriendRequests"]) for uid, profile in migrated.items()}
    raw_received = {uid: set(profile[0]["receivedFriendRequests"]) for uid, profile in migrated.items()}
    valid_friends: dict[str, list[str]] = {}
    for uid, (private, _) in migrated.items():
        valid_friends[uid] = [
            peer for peer in private["friends"]
            if peer != uid and peer in migrated and uid in raw_friends.get(peer, set())
        ]
    friend_pairs = {(uid, peer) for uid, peers in valid_friends.items() for peer in peers}
    valid_requests: set[tuple[str, str]] = set()  # (sender UID, recipient UID)
    for sender, targets in raw_sent.items():
        for recipient in targets:
            if sender == recipient or recipient not in migrated:
                continue
            if sender not in raw_received.get(recipient, set()):
                continue
            if (sender, recipient) in friend_pairs or (recipient, sender) in friend_pairs:
                continue
            valid_requests.add((sender, recipient))
    # Crossed pending requests are ambiguous; discard both rather than auto-accept.
    crossed = {(a, b) for a, b in valid_requests if (b, a) in valid_requests}
    valid_requests -= crossed

    for uid, (private, _) in migrated.items():
        private["friends"] = valid_friends[uid]
        private["sentFriendRequests"] = [peer for peer in private["sentFriendRequests"] if (uid, peer) in valid_requests]
        private["receivedFriendRequests"] = [peer for peer in private["receivedFriendRequests"] if (peer, uid) in valid_requests]
        migrated[uid] = (private, build_public_profile(private))

    existing_public = list(db.collection("public_profiles").stream())
    existing_usernames = list(db.collection("usernames").stream())
    existing_inbox_docs = []
    for doc in db.collection_group("inbox").stream():
        parts = doc.reference.path.split("/")
        if len(parts) == 4 and parts[0] == "friend_requests" and parts[2] == "inbox":
            existing_inbox_docs.append(doc)

    operations: list[tuple[str, Any, Any]] = []
    for uid, (private, public) in migrated.items():
        operations.append(("set", db.collection("users").document(uid), private))
        operations.append(("set", db.collection("public_profiles").document(uid), public))
    for uid, minimal in incomplete.items():
        operations.append(("set", db.collection("users").document(uid), minimal))

    all_valid_uids = set(migrated)
    for doc in existing_public:
        if doc.id not in all_valid_uids:
            operations.append(("delete", doc.reference, None))

    # Reconcile immutable username-index docs to the profiles that actually own them.
    target_usernames: dict[str, tuple[str, Any]] = {}
    for uid, (private, _) in migrated.items():
        username_id = private["usernameNormalized"]
        target_usernames[username_id] = (uid, None)
    existing_username_data = {doc.id: doc.to_dict() or {} for doc in existing_usernames}
    for username_id, (uid, _) in target_usernames.items():
        previous = existing_username_data.get(username_id, {})
        created_at = previous.get("createdAt") if previous.get("uid") == uid and valid_timestamp(previous.get("createdAt")) else firestore.SERVER_TIMESTAMP
        operations.append(("set", db.collection("usernames").document(username_id), {
            "uid": uid, "username": username_id, "createdAt": created_at,
        }))
    for doc in existing_usernames:
        if doc.id not in target_usernames:
            operations.append(("delete", doc.reference, None))

    # Rebuild the subcollection documents that mirror the reciprocal request arrays.
    desired_request_keys = {(recipient, sender) for sender, recipient in valid_requests}
    existing_request_keys: set[tuple[str, str]] = set()
    existing_request_data: dict[tuple[str, str], dict[str, Any]] = {}
    for doc in existing_inbox_docs:
        parts = doc.reference.path.split("/")
        recipient, sender = parts[1], parts[3]
        key = (recipient, sender)
        existing_request_keys.add(key)
        existing_request_data[key] = doc.to_dict() or {}
        if key not in desired_request_keys:
            operations.append(("delete", doc.reference, None))
    for recipient, sender in desired_request_keys:
        old = existing_request_data.get((recipient, sender), {})
        created_at = old.get("createdAt") if valid_timestamp(old.get("createdAt")) else firestore.SERVER_TIMESTAMP
        operations.append(("set", db.collection("friend_requests").document(recipient).collection("inbox").document(sender), {
            "senderUid": sender, "recipientUid": recipient, "createdAt": created_at,
        }))

    print(f"Utenti letti: {len(source_users)}; profili completati: {len(migrated)}; profili incompleti ripuliti: {len(incomplete)}")
    print(f"Amicizie reciproche mantenute: {sum(len(p[0]['friends']) for p in migrated.values()) // 2}; richieste valide: {len(valid_requests)}")
    print(f"Operazioni previste: {len(operations)}; modalità: {'APPLY' if args.apply else 'DRY-RUN (nessuna scrittura)'}")

    if args.apply:
        for offset in range(0, len(operations), 400):
            batch = db.batch()
            for operation, ref, value in operations[offset:offset + 400]:
                if operation == "set":
                    batch.set(ref, value)  # replace: remove legacy/unapproved fields
                else:
                    batch.delete(ref)
            batch.commit()
        print("Migrazione completata. Ora distribuisci firestore.rules.")
    else:
        print("Nessuna scrittura eseguita. Fai un backup e ripeti con --apply per applicare la migrazione.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
