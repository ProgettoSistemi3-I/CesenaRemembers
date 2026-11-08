import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/validation/profile_validation.dart';

void main() {
  group('ProfileValidation', () {
    test('normalizes usernames by trimming, lowercasing and removing unsupported characters', () {
      expect(ProfileValidation.normalizeUsername('  LoRenzo Osto!_17  '), 'lorenzoosto_17');
    });

    test('enforces display-name boundaries after trimming', () {
      expect(ProfileValidation.isValidDisplayName(' A '), isFalse);
      expect(ProfileValidation.isValidDisplayName(' AB '), isTrue);
      expect(ProfileValidation.isValidDisplayName(List.filled(30, 'A').join()), isTrue);
      expect(ProfileValidation.isValidDisplayName(List.filled(31, 'A').join()), isFalse);
    });

    test('enforces normalized username length boundaries', () {
      expect(ProfileValidation.isValidUsername('ab'), isFalse);
      expect(ProfileValidation.isValidUsername('abc'), isTrue);
      expect(ProfileValidation.isValidUsername(List.filled(20, 'a').join()), isTrue);
      expect(ProfileValidation.isValidUsername(List.filled(21, 'a').join()), isFalse);
    });

    test('blocks offensive words without rejecting harmless substrings', () {
      expect(ProfileValidation.hasOffensiveDisplayName('cazzo'), isTrue);
      expect(ProfileValidation.hasOffensiveDisplayName('Bazzocchi'), isFalse);
      expect(ProfileValidation.hasOffensiveDisplayName('Lorenzo Ostolani'), isFalse);
    });

    test('detects offensive username prefixes and suffixes after normalization', () {
      expect(ProfileValidation.hasOffensiveUsername('cazzomio'), isTrue);
      expect(ProfileValidation.hasOffensiveUsername('mio.cazzo'), isTrue);
      expect(ProfileValidation.hasOffensiveUsername('bazzocchi'), isFalse);
      expect(ProfileValidation.hasOffensiveUsername('lorenzo_17'), isFalse);
    });
  });
}
