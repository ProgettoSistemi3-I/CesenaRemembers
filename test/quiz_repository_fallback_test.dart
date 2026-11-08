import 'package:cesena_remembers/data/quiz_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('falls back to local questions when the quiz API returns an HTTP error', () async {
    final client = MockClient((request) async {
      expect(request.url.scheme, 'https');
      expect(request.url.path, '/api/generate-quiz');
      expect(request.headers['authorization'], 'Bearer test-token');
      return http.Response('service unavailable', 503);
    });

    final repository = QuizRepositoryImpl(
      httpClient: client,
      idTokenProvider: () async => 'test-token',
    );

    final result = await repository.getQuizForPoi(
      'rocca',
      'Rocca Malatestiana',
      876543,
      languageCode: 'it',
      poiDescription: '',
    );

    expect(result.usesPersonalizedQuestions, isFalse);
    expect(result.questions, hasLength(3));
    expect(result.fallbackNotice, isNotNull);
    for (final question in result.questions) {
      expect(question.options.length, greaterThanOrEqualTo(3));
      expect(question.correctIndex, inInclusiveRange(0, question.options.length - 1));
      expect(question.options.toSet(), hasLength(question.options.length));
    }
  });

  test('falls back when the API returns an invalid number of questions', () async {
    final client = MockClient((request) async {
      return http.Response(
        '{"questions":[{"question":"only one"}]}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final repository = QuizRepositoryImpl(
      httpClient: client,
      idTokenProvider: () async => 'another-test-token',
    );

    final result = await repository.getQuizForPoi(
      'stazione',
      'Stazione',
      876544,
      languageCode: 'en',
      poiDescription: 'Historical facts',
    );

    expect(result.usesPersonalizedQuestions, isFalse);
    expect(result.questions, hasLength(3));
    expect(result.fallbackDifficultyLabel, isNotNull);
  });
}
