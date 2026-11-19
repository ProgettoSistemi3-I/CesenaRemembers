part of 'map_page.dart';

extension _MapPageTourActions on _MapPageState {
  Future<void> _startTour() async {
    if (!_tourController.hasStops) return;
    // Permission prompts are handled during onboarding or from Settings.
    // Starting a tour must only inspect the current state: requesting again
    // here caused a delayed, redundant Android location prompt.
    await _verifyLocationState(requestPerms: false);
    if (!mounted) return;

    final appGpsPreferenceEnabled = LocationPreferenceStore.gpsEnabled.value;
    final canStartTour =
        appGpsPreferenceEnabled && _isGpsEnabled && _hasPermissions;
    if (_isGpsPreferenceEnabled != appGpsPreferenceEnabled) {
      _updateMapState(() => _isGpsPreferenceEnabled = appGpsPreferenceEnabled);
    }
    if (!canStartTour) {
      AppLogger.error(
        'Tour start blocked by location state: '
        'appPreference=$appGpsPreferenceEnabled, '
        'gpsEnabled=$_isGpsEnabled, locationPermission=$_hasPermissions',
        name: 'MapPageTour',
      );
      showGlassSnackBar(
        context,
        message: AppLocalizations.of(context)!.tourStartGpsRequired,
        type: GlassSnackType.error,
      );
      _resolveLocationIssues();
      return;
    }

    final origin = await _getCurrentDeviceLocation();
    if (!mounted) return;
    if (origin == null) {
      showGlassSnackBar(
        context,
        message: AppLocalizations.of(context)!.tourStartLocationUnavailable,
        type: GlassSnackType.error,
        duration: const Duration(seconds: 6),
      );
      return;
    }
    if (!_MapPageState._cesenaBounds.contains(origin)) {
      _showOutsideCesenaNotification();
      return;
    }
    _removeOutsideCesenaNotification();

    if (!mounted) return;

    final hasStarted = await _tourController.startTour(origin: origin);
    if (hasStarted) {
      _tourXpEarned = 0;
      _tourCorrectAnswers = 0;
      _tourTotalQuestions = 0;
      if (_tourController.currentStop != null) {
        _centerOnStop(_toLatLng(_tourController.currentStop!.position));
      }
      await _syncTourForegroundService(showError: true);
    }
  }

  /// Serializes native service operations and always uses the latest controller
  /// state. Repeated timer ticks do not restart the service for the same stop.
  Future<void> _syncTourForegroundService({
    bool force = false,
    bool showError = false,
  }) {
    final scheduledStop = _tourController.currentStop;
    final scheduledElapsedRunning =
        _tourController.status == TourStatus.running;
    final scheduledLegStartedAt = _tourController.currentLegStartedAtEpochMs;
    if (!force &&
        _tourController.isActive &&
        _foregroundServiceStarted &&
        _lastForegroundStopId == scheduledStop?.id &&
        _lastForegroundElapsedRunning == scheduledElapsedRunning &&
        _lastForegroundLegStartedAtEpochMs == scheduledLegStartedAt) {
      return _foregroundServiceQueue;
    }
    if (!force && !_tourController.isActive && !_foregroundServiceStarted) {
      return _foregroundServiceQueue;
    }

    final operation = _foregroundServiceQueue.then((_) async {
      if (!mounted) return;

      final currentStop = _tourController.currentStop;
      if (!_tourController.isActive || currentStop == null) {
        if (_foregroundServiceStarted) {
          await TourForegroundService.stop();
        }
        _foregroundServiceStarted = false;
        _lastForegroundStopId = null;
        _lastForegroundElapsedRunning = null;
        _lastForegroundLegStartedAtEpochMs = null;
        return;
      }

      final elapsedRunning = _tourController.status == TourStatus.running;
      final legStartedAtEpochMs = _tourController.currentLegStartedAtEpochMs;
      if (!force &&
          _foregroundServiceStarted &&
          _lastForegroundStopId == currentStop.id &&
          _lastForegroundElapsedRunning == elapsedRunning &&
          _lastForegroundLegStartedAtEpochMs == legStartedAtEpochMs) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      final notificationVisible = await TourForegroundService.startOrUpdate(
        notificationTitle: l10n.tourNotificationTitle,
        notificationChannelName: l10n.tourNotificationChannel,
        nextStopLabel: l10n.tourNotificationNextStop,
        elapsedLabel: l10n.tourNotificationElapsed,
        distanceLabel: l10n.tourNotificationDistance,
        openMapLabel: l10n.notificationOpenAction,
        stopName: l10n.getPoiName(currentStop.id),
        latitude: currentStop.position.latitude,
        longitude: currentStop.position.longitude,
        elapsedSeconds: _tourController.elapsedSeconds,
        elapsedRunning: elapsedRunning,
        legStartedAtEpochMs: legStartedAtEpochMs,
      );
      _foregroundServiceStarted = true;
      _lastForegroundStopId = currentStop.id;
      _lastForegroundElapsedRunning = elapsedRunning;
      _lastForegroundLegStartedAtEpochMs = legStartedAtEpochMs;

      if (!notificationVisible && showError && mounted) {
        showGlassSnackBar(
          context,
          message: l10n.tourNotificationPermissionDenied,
          type: GlassSnackType.info,
          duration: const Duration(seconds: 8),
        );
      }
    });

    _foregroundServiceQueue = operation.catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _foregroundServiceStarted = false;
      _lastForegroundStopId = null;
      _lastForegroundElapsedRunning = null;
      _lastForegroundLegStartedAtEpochMs = null;
      AppLogger.error(
        'Unable to synchronize the tour foreground service',
        error: error,
        stackTrace: stackTrace,
        name: 'MapPageTour',
      );
      if (showError && mounted) {
        showGlassSnackBar(
          context,
          message: AppLocalizations.of(context)!.tourBackgroundServiceError,
          type: GlassSnackType.error,
          duration: const Duration(seconds: 8),
        );
      }
    });
    return _foregroundServiceQueue;
  }

  Future<void> _confirmStopTour() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(AppLocalizations.of(context)!.tourConfirmStopTitle),
          content: Text(AppLocalizations.of(context)!.tourConfirmStopBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                AppLocalizations.of(context)!.buttonCancel,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppPalette.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppLocalizations.of(context)!.buttonStop),
            ),
          ],
        );
      },
    );

    if (shouldStop != true || !mounted) return;

    _tourController.stopTour();
    showGlassSnackBar(
      context,
      message: AppLocalizations.of(context)!.tourStopped,
      type: GlassSnackType.error,
      icon: Icons.stop_circle_outlined,
    );
  }

  void _openTourPlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final stops = _tourController.upcomingStops;
            final distances = _tourController.upcomingStopsDistanceFromPrevious;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.68,
              child: TourPlanSheet(
                upcomingStops: stops,
                distanceFromPrevious: distances,
                onReorder: (oldIndex, newIndex) {
                  _tourController.reorderUpcomingStops(
                    oldRelativeIndex: oldIndex,
                    newRelativeIndex: newIndex,
                  );
                  setModalState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }

  void _centerOnStop(LatLng position) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _mapController.move(position, 17.0);
      _updateMapState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
    });
  }

  Future<void> _openPoiPopup() async {
    final currentStop = _tourController.currentStop;
    if (currentStop == null) return;
    final visual = _tourStopVisuals.forStop(currentStop);

    int userXp = _cachedUserXp ?? 0;
    if (_cachedUserXp == null) {
      try {
        final uid = _profileUseCases.getCurrentUserUid();
        if (uid != null) {
          final profile = await _profileUseCases.getUserProfile(uid);
          userXp = profile.xp;
          _cachedUserXp = userXp;
        }
      } catch (error, stackTrace) {
        AppLogger.error(
          'Unable to refresh the player XP before showing tour completion',
          error: error,
          stackTrace: stackTrace,
          name: 'MapPageTour',
        );
      }
    }
    if (!mounted) return;

    final isLastStop =
        _tourController.currentStopIndex ==
        _tourController.orderedStops.length - 1;
    var isAdvancingToNextStop = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => PoiBottomSheet(
        stop: currentStop,
        icon: visual.icon,
        iconBackground: visual.iconBackground,
        elapsedSeconds: _tourController.elapsedSeconds,
        userXp: userXp,
        onClose: () async {
          await _confirmStopTour();
          if (mounted && sheetContext.mounted && !_tourController.isActive) {
            Navigator.of(sheetContext).pop();
          }
        },
        isFinalStop: isLastStop,
        onNextStop: () {
          if (isAdvancingToNextStop) return;
          isAdvancingToNextStop = true;
          if (!mounted || !sheetContext.mounted) return;

          // La navigazione non aspetta Firestore: il risultato è già stato
          // acquisito localmente e il salvataggio remoto continua in coda.
          Navigator.of(sheetContext).pop();
          if (_tourController.advanceToNextStop()) {
            final nextStop = _tourController.currentStop;
            if (nextStop != null) {
              _centerOnStop(_toLatLng(nextStop.position));
            }
          } else {
            showGeneralDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.transparent,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (dialogContext, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: TourCompletionAnimation(
                    xpGained: _tourXpEarned,
                    onDismiss: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                );
              },
            );
          }
        },
        onQuizCompleted: (result) {
          unawaited(
            _registerQuizCompletion(
              currentStop.id,
              result,
              isLastStop: isLastStop,
            ),
          );
        },
      ),
    );
  }

  Future<void> _registerQuizCompletion(
    String poiId,
    QuizCompletionData result, {
    bool isLastStop = false,
  }) {
    final uid = _profileUseCases.getCurrentUserUid();
    if (uid == null) return Future<void>.value();

    final score = _tourScoringService.calculate(
      correctAnswers: result.score,
      legElapsedSeconds: _tourController.elapsedSeconds,
    );
    final nextTourXp = _tourXpEarned + score.totalXp;
    final nextTourCorrect = _tourCorrectAnswers + result.score;
    final nextTourQuestions = _tourTotalQuestions + result.totalQuestions;
    final elapsedAtCompletion = _tourController.totalElapsedSeconds;

    // Update local state immediately so the next-stop button and completion
    // animation never wait for a network round trip.
    _tourXpEarned = nextTourXp;
    _tourCorrectAnswers = nextTourCorrect;
    _tourTotalQuestions = nextTourQuestions;
    // Do not turn a failed profile read into a cached zero baseline.
    // Leave the cache empty so the next POI popup can retry loading the real XP.
    if (_cachedUserXp != null) {
      _cachedUserXp = _cachedUserXp! + score.totalXp;
    }

    unawaited(
      _tourSessionStore
          .saveResults(
            TourSessionResults(
              xpEarned: nextTourXp,
              correctAnswers: nextTourCorrect,
              totalQuestions: nextTourQuestions,
            ),
          )
          .catchError((Object error, StackTrace stackTrace) {
            AppLogger.error(
              'Unable to persist local tour quiz results',
              error: error,
              stackTrace: stackTrace,
              name: 'MapPageTour',
            );
          }),
    );

    final l10n = AppLocalizations.of(context)!;
    final xpText = l10n.tourXpEarned(score.totalXp);
    showGlassSnackBar(
      context,
      message: score.tier == SpeedTier.none
          ? xpText
          : '$xpText · ${l10n.speedBonusLabel(score.tier, score.bonusPercent)}',
      type: GlassSnackType.xp,
      icon: Icons.bolt_rounded,
      duration: const Duration(seconds: 4),
    );

    return _enqueueQuizSave({
      'uid': uid,
      'poiId': poiId,
      'xpGained': score.totalXp,
      'correctAnswers': result.score,
      'totalQuestions': result.totalQuestions,
      'tourElapsedSeconds': elapsedAtCompletion,
      'isTourComplete': isLastStop,
      'tourTotalXp': nextTourXp,
      'tourCorrectAnswers': nextTourCorrect,
      'tourTotalQuestions': nextTourQuestions,
    });
  }

  Future<void> _loadPendingQuizSaves() async {
    if (_pendingQuizSavesLoaded) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getString('pending_quiz_saves_v1');
      if (encoded != null) {
        final decoded = jsonDecode(encoded) as List<dynamic>;
        _pendingQuizSaves.addAll(
          decoded.cast<Map>().map((item) => Map<String, dynamic>.from(item)),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to load pending quiz saves',
        error: error,
        stackTrace: stackTrace,
        name: 'MapPageTour',
      );
    }
    _pendingQuizSavesLoaded = true;
    if (_pendingQuizSaves.isNotEmpty) {
      _quizSaveQueue = _quizSaveQueue.then((_) => _drainPendingQuizSaves());
    }
  }

  Future<void> _enqueueQuizSave(Map<String, dynamic> save) async {
    await _loadPendingQuizSaves();
    _pendingQuizSaves.add(save);
    await _persistPendingQuizSaves();
    final operation = _quizSaveQueue.then((_) => _drainPendingQuizSaves());
    _quizSaveQueue = operation;
    await operation;
  }

  Future<void> _persistPendingQuizSaves() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        'pending_quiz_saves_v1',
        jsonEncode(_pendingQuizSaves),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to persist pending quiz saves',
        error: error,
        stackTrace: stackTrace,
        name: 'MapPageTour',
      );
    }
  }

  Future<void> _drainPendingQuizSaves() async {
    while (_pendingQuizSaves.isNotEmpty) {
      final save = _pendingQuizSaves.first;
      var saved = false;
      Object? lastError;
      StackTrace? lastStackTrace;
      for (var attempt = 0; attempt < 3 && !saved; attempt++) {
        try {
          await _progressUseCases.registerQuizCompletion(
            uid: save['uid'] as String,
            poiId: save['poiId'] as String,
            xpGained: save['xpGained'] as int,
            correctAnswers: save['correctAnswers'] as int,
            totalQuestions: save['totalQuestions'] as int,
            tourElapsedSeconds: save['tourElapsedSeconds'] as int,
            isTourComplete: save['isTourComplete'] as bool,
            tourTotalXp: save['tourTotalXp'] as int,
            tourCorrectAnswers: save['tourCorrectAnswers'] as int,
            tourTotalQuestions: save['tourTotalQuestions'] as int,
          );
          saved = true;
        } catch (error, stackTrace) {
          lastError = error;
          lastStackTrace = stackTrace;
          if (attempt < 2) await Future.delayed(Duration(seconds: attempt + 1));
        }
      }
      if (!saved) {
        AppLogger.error(
          'Quiz save remains queued for retry',
          error: lastError,
          stackTrace: lastStackTrace,
          name: 'MapPageTour',
        );
        _quizSaveRetryTimer?.cancel();
        _quizSaveRetryTimer = Timer(const Duration(seconds: 30), () {
          if (!mounted) return;
          _quizSaveQueue = _quizSaveQueue.then((_) => _drainPendingQuizSaves());
        });
        if (mounted) {
          final debugDetails = kDebugMode
              ? '\n${lastError.runtimeType}: $lastError'
              : '';
          showGlassSnackBar(
            context,
            message:
                '${AppLocalizations.of(context)!.errorSaveScore}$debugDetails',
            type: GlassSnackType.error,
            duration: const Duration(seconds: 8),
          );
        }
        return;
      }
      _pendingQuizSaves.removeAt(0);
      await _persistPendingQuizSaves();
    }
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
