import 'dart:convert';

import 'package:cesena_remembers/data/quiz_repository_impl.dart';
import 'package:cesena_remembers/domain/entities/quiz_question.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('QuizQuestion parses an integral JSON double as an answer index', () {
    final question = QuizQuestion.fromJson({
      'question': 'Which option is correct?',
      'options': ['A', 'B', 'C'],
      'correctIndex': 1.0,
    });

    expect(question.correctIndex, 1);
  });

  test('a completed attempt can invalidate the POI quiz cache', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      return http.Response(
        jsonEncode({
          'questions': List.generate(
            3,
            (index) => {
              'question': 'Question $index?',
              'options': ['Wrong', 'Correct', 'Other'],
              'correctIndex': index == 0 ? 1.0 : 0,
            },
          ),
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = QuizRepositoryImpl(
      httpClient: client,
      idTokenProvider: () async => 'cache-test-token',
    );

    final first = await repository.getQuizForPoi(
      'cache_invalidation_test',
      'Test POI',
      0,
      languageCode: 'it',
      poiDescription: '',
    );
    final cached = await repository.getQuizForPoi(
      'cache_invalidation_test',
      'Test POI',
      0,
      languageCode: 'it',
      poiDescription: '',
    );

    expect(requestCount, 1);
    expect(cached.questions, hasLength(3));
    expect(cached.questions.first.correctIndex, 1);
    expect(identical(first, cached), isTrue);

    repository.invalidateCacheForPoi('cache_invalidation_test');
    final refreshed = await repository.getQuizForPoi(
      'cache_invalidation_test',
      'Test POI',
      0,
      languageCode: 'it',
      poiDescription: '',
    );

    expect(requestCount, 2);
    expect(refreshed.questions, hasLength(3));
  });
}
