import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cesena_remembers/domain/entities/app_user.dart';
import 'package:cesena_remembers/domain/repositories/auth_repository.dart';
import 'package:cesena_remembers/injection_container.dart';
import 'package:cesena_remembers/presentation/services/auth_gate.dart';

class _SignedOutAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> get userStream => Stream<AppUser?>.value(null);

  @override
  Future<AppUser?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> reauthenticateCurrentUser() async {}

  @override
  Future<void> deleteCurrentUser() async {}
}

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerSingleton<AuthRepository>(_SignedOutAuthRepository());
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('AuthGate renders the signed-out route when auth emits null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          loginBuilder: (_) => const Text('Signed-out route'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Signed-out route'), findsOneWidget);
  });
}
