import 'dart:convert';

import 'package:cesena_remembers/data/quiz_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sends the current Firebase ID token as a Bearer token', () async {
    http.BaseRequest? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'questions': List.generate(
            3,
            (index) => {
              'question': 'Question number $index?',
              'options': ['Option A', 'Option B', 'Option C', 'Option D'],
              'correctIndex': index,
            },
          ),
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final repository = QuizRepositoryImpl(
      httpClient: client,
      idTokenProvider: () async => 'test-firebase-id-token',
    );

    final result = await repository.getQuizForPoi(
      'rocca',
      'Rocca Malatestiana',
      999990,
      languageCode: 'it',
      poiDescription: '',
    );

    expect(result.usesPersonalizedQuestions, isTrue);
    expect(result.questions, hasLength(3));
    expect(capturedRequest, isNotNull);
    expect(capturedRequest!.headers['authorization'],
        'Bearer test-firebase-id-token');
    expect(capturedRequest!.url.path, '/api/generate-quiz');
  });

  test('does not call the remote API when no Firebase user is signed in', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount++;
      return http.Response('{}', 200);
    });

    final repository = QuizRepositoryImpl(
      httpClient: client,
      idTokenProvider: () async => null,
    );

    final result = await repository.getQuizForPoi(
      'rocca',
      'Rocca Malatestiana',
      999991,
      languageCode: 'it',
      poiDescription: '',
    );

    expect(requestCount, 0);
    expect(result.usesPersonalizedQuestions, isFalse);
    expect(result.questions, isNotEmpty);
  });
}
