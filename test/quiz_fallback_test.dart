import 'package:cesena_remembers/data/quiz_repository_impl.dart';
import 'package:cesena_remembers/data/seeds/historic_places_seed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  for (final place in HistoricPlacesSeed.items) {
    test('fallback quiz for ${place.id} contains exactly three questions', () async {
      final client = MockClient(
        (_) async => http.Response('Quiz service unavailable', 503),
      );
      addTearDown(client.close);

      final repository = QuizRepositoryImpl(httpClient: client);
      final result = await repository.getQuizForPoi(
        place.id,
        place.name,
        0,
        languageCode: 'it',
        poiDescription: place.description,
      );

      expect(result.usesPersonalizedQuestions, isFalse);
      expect(result.questions, hasLength(3));
    });
  }
}
