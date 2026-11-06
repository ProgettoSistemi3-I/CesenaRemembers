import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_runtime_config.dart';
import '../core/logging/app_logger.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             clientId: AppRuntimeConfig.googleWebClientId.trim().isEmpty
                 ? null
                 : AppRuntimeConfig.googleWebClientId,
           );

  @override
  Stream<AppUser?> get userStream {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    });
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    // Forza il selettore account per evitare il riutilizzo silenzioso di
    // una sessione Google precedente.
    try {
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Google sign-in failed while clearing the previous Google session',
        error: error,
        stackTrace: stackTrace,
        name: 'FirebaseAuthRepository',
      );
      rethrow;
    }

    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Google account selection failed',
        error: error,
        stackTrace: stackTrace,
        name: 'FirebaseAuthRepository',
      );
      rethrow;
    }

    if (googleUser == null) {
      AppLogger.info(
        'Google account selection was cancelled',
        name: 'FirebaseAuthRepository',
      );
      return null;
    }

    GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await googleUser.authentication;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Google authentication token retrieval failed',
        error: error,
        stackTrace: stackTrace,
        name: 'FirebaseAuthRepository',
      );
      rethrow;
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        AppLogger.error(
          'Firebase accepted Google credentials but returned no user',
          name: 'FirebaseAuthRepository',
        );
        return null;
      }
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error(
        'Firebase sign-in rejected Google credentials (code: ${error.code})',
        error: error,
        stackTrace: stackTrace,
        name: 'FirebaseAuthRepository',
      );
      if (error.code == 'user-disabled') {
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'user-disabled',
        );
      }
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unexpected error while exchanging Google credentials with Firebase',
        error: error,
        stackTrace: stackTrace,
        name: 'FirebaseAuthRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> reauthenticateCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final googleUser =
        await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Re-authentication required but cancelled by user.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    // La riautenticazione viene eseguita prima della cancellazione dei dati
    // Firestore dal flusso di SettingsController. Qui non va più ritentata
    // dopo che la pulizia remota è stata completata.
    await user.delete();

    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
    } catch (_) {
      try {
        await _googleSignIn.signOut();
      } catch (error, stackTrace) {
        AppLogger.error(
          'Google account sign-out fallback failed',
          error: error,
          stackTrace: stackTrace,
          name: 'FirebaseAuthRepository',
        );
      }
    }
  }
}
