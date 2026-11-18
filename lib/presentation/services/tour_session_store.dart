import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TourSessionSnapshot {
  const TourSessionSnapshot({
    required this.orderedStopIds,
    required this.currentStopIndex,
    required this.status,
    required this.elapsedSeconds,
    required this.totalElapsedSeconds,
    required this.savedAtEpochMs,
    required this.startedAtEpochMs,
    this.userLatitude,
    this.userLongitude,
    this.userPositionAtEpochMs,
  });

  final List<String> orderedStopIds;
  final int currentStopIndex;
  final String status;
  final int elapsedSeconds;
  final int totalElapsedSeconds;
  final int savedAtEpochMs;
  final int startedAtEpochMs;
  final double? userLatitude;
  final double? userLongitude;
  final int? userPositionAtEpochMs;

  Map<String, Object?> toJson() => {
    'orderedStopIds': orderedStopIds,
    'currentStopIndex': currentStopIndex,
    'status': status,
    'elapsedSeconds': elapsedSeconds,
    'totalElapsedSeconds': totalElapsedSeconds,
    'savedAtEpochMs': savedAtEpochMs,
    'startedAtEpochMs': startedAtEpochMs,
    'userLatitude': userLatitude,
    'userLongitude': userLongitude,
    'userPositionAtEpochMs': userPositionAtEpochMs,
  };

  factory TourSessionSnapshot.fromJson(Map<String, dynamic> json) {
    final rawStopIds = json['orderedStopIds'];
    if (rawStopIds is! List) {
      throw const FormatException('Invalid tour stop list');
    }

    final stopIds = rawStopIds.whereType<String>().toList(growable: false);
    final status = json['status'];
    if (status != 'running' && status != 'arrived') {
      throw const FormatException('Invalid tour status');
    }

    return TourSessionSnapshot(
      orderedStopIds: stopIds,
      currentStopIndex: _readInt(json, 'currentStopIndex'),
      status: status as String,
      elapsedSeconds: _readInt(json, 'elapsedSeconds'),
      totalElapsedSeconds: _readInt(json, 'totalElapsedSeconds'),
      savedAtEpochMs: _readInt(json, 'savedAtEpochMs'),
      startedAtEpochMs: _readInt(json, 'startedAtEpochMs'),
      userLatitude: _readDouble(json, 'userLatitude'),
      userLongitude: _readDouble(json, 'userLongitude'),
      userPositionAtEpochMs: _readNullableInt(json, 'userPositionAtEpochMs'),
    );
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toInt();
    throw FormatException('Invalid tour field: $key');
  }

  static int? _readNullableInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is num ? value.toInt() : null;
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is num ? value.toDouble() : null;
  }
}

class TourSessionResults {
  const TourSessionResults({
    required this.xpEarned,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  final int xpEarned;
  final int correctAnswers;
  final int totalQuestions;

  Map<String, Object?> toJson() => {
    'xpEarned': xpEarned,
    'correctAnswers': correctAnswers,
    'totalQuestions': totalQuestions,
  };

  factory TourSessionResults.fromJson(Map<String, dynamic> json) {
    int readInt(String key) {
      final value = json[key];
      return value is num ? value.toInt() : 0;
    }

    return TourSessionResults(
      xpEarned: readInt('xpEarned'),
      correctAnswers: readInt('correctAnswers'),
      totalQuestions: readInt('totalQuestions'),
    );
  }
}

/// Stores the active tour locally so the UI can restore it after process death.
class TourSessionStore {
  static const _sessionKey = 'active_tour_session_v1';
  static const _resultsKey = 'active_tour_results_v1';

  Future<TourSessionSnapshot?> loadSession() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid tour session payload');
      }
      return TourSessionSnapshot.fromJson(decoded);
    } catch (_) {
      await preferences.remove(_sessionKey);
      return null;
    }
  }

  Future<void> saveSession(TourSessionSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }

  Future<TourSessionResults?> loadResults() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_resultsKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid tour result payload');
      }
      return TourSessionResults.fromJson(decoded);
    } catch (_) {
      await preferences.remove(_resultsKey);
      return null;
    }
  }

  Future<void> saveResults(TourSessionResults results) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_resultsKey, jsonEncode(results.toJson()));
  }

  Future<void> clearResults() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_resultsKey);
  }
}
