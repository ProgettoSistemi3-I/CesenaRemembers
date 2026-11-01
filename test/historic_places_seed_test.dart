import 'package:flutter_test/flutter_test.dart';
import 'package:cesena_remembers/data/seeds/historic_places_seed.dart';

void main() {
  test('every historic place has three valid, place-specific fallback questions', () {
    expect(HistoricPlacesSeed.items, isNotEmpty);

    for (final place in HistoricPlacesSeed.items) {
      expect(place.questions, hasLength(3), reason: place.id);

      for (final question in place.questions) {
        expect(question.question, startsWith('quiz_${place.id}_'), reason: place.id);
        expect(question.options, hasLength(3), reason: place.id);
        expect(question.options.toSet(), hasLength(3), reason: place.id);
        expect(question.options.every((option) => option.isNotEmpty), isTrue, reason: place.id);
        expect(question.correctIndex, inInclusiveRange(0, 2), reason: place.id);
      }
    }
  });
}
