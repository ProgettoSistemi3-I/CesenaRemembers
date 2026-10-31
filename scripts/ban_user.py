#!/usr/bin/env python3
"""Script di gestione ban utenti per Cesena Remembers.

Banna un utente e/o ripulisce le sue proiezioni pubbliche e statistiche:
- Inserisce l'utente nella collection 'banned_users' (con data e motivazione).
- Cancella le proiezioni pubbliche e statistiche:
    - leaderboard/{uid}
    - public_profiles/{uid}
    - friend_stats/{uid}
    - usernames/{usernameNormalized}
- Rimuove l'utente dalle liste amici e richieste pendenti per prevenire account fantasma.

Dry-run predefinito. Richiede GOOGLE_APPLICATION_CREDENTIALS con un service
account protetto fuori dal repository. Usare --apply per scrivere su Firestore.

Esempi:
    # Banna un utente ed elimina le sue proiezioni (dry-run):
    python scripts/ban_user.py --uid USER_UID --reason "Contenuti inappropriati"

    # Applica il ban effettivo:
    python scripts/ban_user.py --uid USER_UID --reason "Contenuti inappropriati" --apply

    # Ripulisce tutte le proiezioni residue degli utenti già presenti in banned_users:
    python scripts/ban_user.py --cleanup-banned --apply
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from typing import Any

import firebase_admin
from firebase_admin import credentials, firestore


def normalize_username(value: str | None) -> str:
    if not value:
        return ""
    return value.strip().lower()


def ban_user(
    db: firestore.Client,
    uid: str,
    reason: str,
    apply: bool,
) -> bool:
    print(f"\n--- Elaborazione Ban per UID: {uid} ---")
    user_ref = db.collection("users").document(uid)
    user_snap = user_ref.get()
    user_data = user_snap.to_dict() or {}

    banned_ref = db.collection("banned_users").document(uid)
    banned_snap = banned_ref.get()

    leaderboard_ref = db.collection("leaderboard").document(uid)
    public_ref = db.collection("public_profiles").document(uid)
    stats_ref = db.collection("friend_stats").document(uid)

    # Identifica l'username da cancellare
    usernames_to_delete: list[firestore.DocumentReference] = []
    username_normalized = (
        user_data.get("usernameNormalized")
        or normalize_username(user_data.get("username"))
    )
    if not username_normalized and public_ref.get().exists:
        pub_data = public_ref.get().to_dict() or {}
        username_normalized = (
            pub_data.get("usernameNormalized")
            or normalize_username(pub_data.get("username"))
        )

    if username_normalized:
        uname_doc = db.collection("usernames").document(username_normalized).get()
        if uname_doc.exists:
            usernames_to_delete.append(uname_doc.reference)

    # Ricerca di sicurezza per eventuali altri record username associati all'UID
    for doc in db.collection("usernames").where("uid", "==", uid).stream():
        if doc.reference not in usernames_to_delete:
            usernames_to_delete.append(doc.reference)

    docs_to_delete: list[tuple[str, firestore.DocumentReference]] = []
    if leaderboard_ref.get().exists:
        docs_to_delete.append(("leaderboard", leaderboard_ref))
    if public_ref.get().exists:
        docs_to_delete.append(("public_profiles", public_ref))
    if stats_ref.get().exists:
        docs_to_delete.append(("friend_stats", stats_ref))
    for uref in usernames_to_delete:
        docs_to_delete.append((f"usernames ({uref.id})", uref))

    print(f"Stato utente: {'Trovato' if user_snap.exists else 'Non presente in users'}")
    print(f"Già in banned_users: {'Sì' if banned_snap.exists else 'No'}")
    print(f"Documenti da cancellare: {[label for label, _ in docs_to_delete] or 'Nessuno'}")

    # Pulizia relazioni sociali se l'utente esiste
    friends = list(user_data.get("friends") or [])
    sent_reqs = list(user_data.get("sentFriendRequests") or [])
    recv_reqs = list(user_data.get("receivedFriendRequests") or [])
    print(f"Relazioni da ripulire: {len(friends)} amici, {len(sent_reqs)} inviate, {len(recv_reqs)} ricevute")

    if not apply:
        print("[DRY-RUN] Nessuna modifica eseguita. Esegui con --apply per confermare il ban e la rimozione.")
        return True

    batch = db.batch()

    # 1. Imposta banned_users
    batch.set(
        banned_ref,
        {
            "uid": uid,
            "reason": reason,
            "bannedAt": firestore.SERVER_TIMESTAMP,
        },
        merge=True,
    )

    # 2. Cancella leaderboard, public_profiles, friend_stats, usernames
    for _, doc_ref in docs_to_delete:
        batch.delete(doc_ref)

    batch.commit()

    # 3. Rimuovi le relazioni sociali dai peer
    for friend_uid in friends:
        try:
            p_batch = db.batch()
            peer_user = db.collection("users").document(friend_uid)
            peer_stats = db.collection("friend_stats").document(friend_uid)
            p_batch.update(peer_user, {
                "friends": firestore.ArrayRemove([uid]),
                "updatedAt": firestore.SERVER_TIMESTAMP,
            })
            p_batch.update(peer_stats, {
                "friends": firestore.ArrayRemove([uid]),
            })
            p_batch.commit()
        except Exception as e:
            print(f"Avviso rimozione amico {friend_uid}: {e}", file=sys.stderr)

    for target_uid in sent_reqs:
        try:
            req_doc = (
                db.collection("friend_requests")
                .document(target_uid)
                .collection("inbox")
                .document(uid)
            )
            req_doc.delete()
            db.collection("users").document(target_uid).update({
                "receivedFriendRequests": firestore.ArrayRemove([uid]),
                "updatedAt": firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            print(f"Avviso rimozione richiesta a {target_uid}: {e}", file=sys.stderr)

    for requester_uid in recv_reqs:
        try:
            req_doc = (
                db.collection("friend_requests")
                .document(uid)
                .collection("inbox")
                .document(requester_uid)
            )
            req_doc.delete()
            db.collection("users").document(requester_uid).update({
                "sentFriendRequests": firestore.ArrayRemove([uid]),
                "updatedAt": firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            print(f"Avviso rimozione richiesta da {requester_uid}: {e}", file=sys.stderr)

    # 4. Aggiorna il documento utente per rimuovere le liste relazionali
    if user_snap.exists:
        try:
            user_ref.update({
                "friends": [],
                "sentFriendRequests": [],
                "receivedFriendRequests": [],
                "isBanned": True,
                "bannedAt": firestore.SERVER_TIMESTAMP,
                "banReason": reason,
                "updatedAt": firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            print(f"Avviso aggiornamento utente {uid}: {e}", file=sys.stderr)

    print(f"Ban e pulizia proiezioni per UID {uid} completati con successo.")
    return True


def cleanup_all_banned(db: firestore.Client, apply: bool) -> int:
    print("\n=== Pulizia proiezioni per TUTTI gli utenti bannati ===")
    banned_docs = list(db.collection("banned_users").stream())
    print(f"Utenti presenti in banned_users: {len(banned_docs)}")
    if not banned_docs:
        print("Nessun utente bannato trovato.")
        return 0

    to_clean_count = 0
    for doc in banned_docs:
        uid = doc.id
        lb_exists = db.collection("leaderboard").document(uid).get().exists
        pub_exists = db.collection("public_profiles").document(uid).get().exists
        fs_exists = db.collection("friend_stats").document(uid).get().exists

        unames = list(db.collection("usernames").where("uid", "==", uid).stream())
        if lb_exists or pub_exists or fs_exists or unames:
            to_clean_count += 1
            print(f"UID bannato {uid} possiede ancora dati residui:")
            if lb_exists:
                print("  - leaderboard")
            if pub_exists:
                print("  - public_profiles")
            if fs_exists:
                print("  - friend_stats")
            for u in unames:
                print(f"  - username: {u.id}")

            if apply:
                batch = db.batch()
                if lb_exists:
                    batch.delete(db.collection("leaderboard").document(uid))
                if pub_exists:
                    batch.delete(db.collection("public_profiles").document(uid))
                if fs_exists:
                    batch.delete(db.collection("friend_stats").document(uid))
                for u in unames:
                    batch.delete(u.reference)
                batch.commit()
                print(f"  -> Pulizia completata per {uid}")

    if not apply:
        print(f"\n[DRY-RUN] Trovati {to_clean_count} utenti con dati residui. Esegui con --apply per ripulire.")
    else:
        print(f"\nPulizia completata per {to_clean_count} utenti bannati.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--uid", help="UID dell'utente da bannare")
    parser.add_argument("--reason", default="Violazione dei termini di servizio", help="Motivazione del ban")
    parser.add_argument("--cleanup-banned", action="store_true", help="Ripulisce leaderboard, public_profiles, friend_stats e usernames per tutti gli utenti in banned_users")
    parser.add_argument("--project-id", help="ID del progetto Firebase")
    parser.add_argument("--apply", action="store_true", help="Esegue le modifiche; senza questo flag è solo dry-run")

    args = parser.parse_args()

    if not args.uid and not args.cleanup_banned:
        parser.print_help()
        print("\nErrore: Specificare --uid <UID> oppure --cleanup-banned.", file=sys.stderr)
        return 1

    key_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not key_path or not Path(key_path).is_file():
        print("Imposta GOOGLE_APPLICATION_CREDENTIALS su un service-account protetto.", file=sys.stderr)
        return 2

    cred = credentials.Certificate(key_path)
    options = {"projectId": args.project_id} if args.project_id else None
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred, options=options)
    db = firestore.client()

    if args.uid:
        ban_user(db, args.uid, args.reason, args.apply)

    if args.cleanup_banned:
        cleanup_all_banned(db, args.apply)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
