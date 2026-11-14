import 'package:flutter/foundation.dart';

import '../../core/logging/app_logger.dart';

import '../../domain/entities/quiz_question.dart';
import '../../domain/usecases/get_poi_quiz_usecases.dart';

class PoiQuizController extends ChangeNotifier {
  final GetPoiQuizUseCase _getQuizUseCase;
  bool _isDisposed = false;

  PoiQuizController({required this._getQuizUseCase});

  List<QuizQuestion> _questions = [];
  int? _selectedAnswer;
  int _questionIndex = 0;
  int _score = 0;
  bool _quizDone = false;
  bool _lastQuestionAnswered = false;
  bool _isLoading = false;
  String? _error;
  bool _usesPersonalizedQuestions = true;
  String? _fallbackNotice;
  String? _fallbackDifficultyLabel;

  int? get selectedAnswer => _selectedAnswer;
  int get questionIndex => _questionIndex;
  int get score => _score;
  bool get quizDone => _quizDone;
  bool get isLastQuestionAnswered => _lastQuestionAnswered;
  bool get hasMoreQuestions => _questionIndex < _questions.length - 1;
  QuizQuestion? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_questionIndex];
  int get totalQuestions => _questions.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get usesPersonalizedQuestions => _usesPersonalizedQuestions;
  String? get fallbackNotice => _fallbackNotice;
  String? get fallbackDifficultyLabel => _fallbackDifficultyLabel;

  Future<void> initQuiz(
    String poiId,
    String poiName,
    int userXp, {
    required String languageCode,
    required String poiDescription,
  }) async {
    if (_isDisposed) return;
    _isLoading = true;
    _error = null;
    _fallbackNotice = null;
    _fallbackDifficultyLabel = null;
    notifyListeners();

    try {
      final result = await _getQuizUseCase(
        poiId,
        poiName,
        userXp,
        languageCode: languageCode,
        poiDescription: poiDescription,
      );
      if (_isDisposed) return;
      _questions = result.questions;
      _usesPersonalizedQuestions = result.usesPersonalizedQuestions;
      _fallbackNotice = result.fallbackNotice;
      _fallbackDifficultyLabel = result.fallbackDifficultyLabel;
      _questionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _quizDone = _questions.isEmpty;
      _lastQuestionAnswered = false;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to load the POI quiz',
        error: error,
        stackTrace: stackTrace,
        name: 'PoiQuizController',
      );
      if (!_isDisposed) _error = 'errorCommunication';
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void selectAnswer(int index) {
    if (_isDisposed) return;
    final question = currentQuestion;
    if (question == null || _selectedAnswer != null) {
      return;
    }
    if (index < 0 || index >= question.options.length) {
      return;
    }

    final isCorrect = index == question.correctIndex;
    _selectedAnswer = index;
    if (isCorrect) {
      _score++;
    }
    _lastQuestionAnswered = !hasMoreQuestions;
    notifyListeners();
  }

  void nextQuestion() {
    if (_isDisposed) return;
    if (_quizDone || !hasMoreQuestions) {
      return;
    }
    _questionIndex++;
    _selectedAnswer = null;
    _lastQuestionAnswered = false;
    notifyListeners();
  }

  void completeQuiz() {
    if (_isDisposed) return;
    if (_quizDone) return;
    if (_questions.isEmpty) {
      _quizDone = true;
      notifyListeners();
      return;
    }
    if (_selectedAnswer == null || !_lastQuestionAnswered) {
      return;
    }
    _quizDone = true;
    notifyListeners();
  }
}
