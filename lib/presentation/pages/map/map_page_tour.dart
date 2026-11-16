part of 'map_page.dart';

extension _MapPageTourActions on _MapPageState {
  Future<void> _startTour() async {
    if (!_tourController.hasStops) return;
    await _verifyLocationState(requestPerms: true);
    final canStartTour =
        _isGpsPreferenceEnabled && _isGpsEnabled && _hasPermissions;
    if (!canStartTour) {
      if (!mounted) return;
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

    // Notification permission is requested during consent onboarding, not
    // after the user starts a tour. If Android still blocks notifications,
    // explain the limitation but do not interrupt the tour with a late prompt.
    try {
      final notificationsEnabled =
          await NotificationService().areAndroidNotificationsEnabled();
      if (notificationsEnabled == false && mounted) {
        showGlassSnackBar(
          context,
          message: AppLocalizations.of(context)!.tourNotificationPermissionDenied,
          type: GlassSnackType.info,
          duration: const Duration(seconds: 6),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to check tour notification permission',
        error: error,
        stackTrace: stackTrace,
        name: 'MapPageTour',
      );
    }
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
    if (!force &&
        _tourController.isActive &&
        _foregroundServiceStarted &&
        _lastForegroundStopId == scheduledStop?.id) {
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
        return;
      }

      if (!force &&
          _foregroundServiceStarted &&
          _lastForegroundStopId == currentStop.id) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      await TourForegroundService.startOrUpdate(
        notificationTitle: l10n.tourNotificationTitle,
        notificationChannelName: l10n.tourNotificationChannel,
        nextStopLabel: l10n.tourNotificationNextStop,
        elapsedLabel: l10n.tourNotificationElapsed,
        distanceLabel: l10n.tourNotificationDistance,
        openMapLabel: l10n.notificationOpenAction,
        stopName: l10n.getPoiName(currentStop.id),
        latitude: currentStop.position.latitude,
        longitude: currentStop.position.longitude,
        startedAtEpochMs: _tourController.tourStartedAtEpochMs,
      );
      _foregroundServiceStarted = true;
      _lastForegroundStopId = currentStop.id;
    });

    _foregroundServiceQueue = operation.catchError(
      (Object error, StackTrace stackTrace) {
        _foregroundServiceStarted = false;
        _lastForegroundStopId = null;
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
      },
    );
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
          content: Text(
            AppLocalizations.of(context)!.tourConfirmStopBody,
          ),
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
    _cachedUserXp = (_cachedUserXp ?? 0) + score.totalXp;

    unawaited(
      _tourSessionStore.saveResults(
        TourSessionResults(
          xpEarned: nextTourXp,
          correctAnswers: nextTourCorrect,
          totalQuestions: nextTourQuestions,
        ),
      ).catchError((Object error, StackTrace stackTrace) {
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
          : '${xpText} · ${l10n.speedBonusLabel(score.tier, score.bonusPercent)}',
      type: GlassSnackType.xp,
      icon: Icons.bolt_rounded,
      duration: const Duration(seconds: 4),
    );

    final queuedSave = _quizSaveQueue.then((_) async {
      try {
        await _progressUseCases.registerQuizCompletion(
          uid: uid,
          poiId: poiId,
          xpGained: score.totalXp,
          correctAnswers: result.score,
          totalQuestions: result.totalQuestions,
          tourElapsedSeconds: elapsedAtCompletion,
          isTourComplete: isLastStop,
          tourTotalXp: nextTourXp,
          tourCorrectAnswers: nextTourCorrect,
          tourTotalQuestions: nextTourQuestions,
        );
      } catch (error, stackTrace) {
        AppLogger.error(
          'Salvataggio punteggio quiz fallito per tappa=$poiId '
          '(xp=${score.totalXp}, risposte=${result.score}/${result.totalQuestions}, '
          'tourCompleto=$isLastStop)',
          error: error,
          stackTrace: stackTrace,
          name: 'MapPageTour',
        );
        if (!mounted) return;
        final debugDetails = kDebugMode
            ? '\n${error.runtimeType}: $error'
            : '';
        showGlassSnackBar(
          context,
          message: '${AppLocalizations.of(context)!.errorSaveScore}$debugDetails',
          type: GlassSnackType.error,
          duration: const Duration(seconds: 8),
        );
      }
    });

    _quizSaveQueue = queuedSave;
    return queuedSave;
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
