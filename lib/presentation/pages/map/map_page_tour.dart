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

    final hasStarted = await _tourController.startTour();
    if (hasStarted) {
      _tourXpEarned = 0;
      _tourCorrectAnswers = 0;
      _tourTotalQuestions = 0;
      _pendingQuizSave = Future<void>.value();
    }
    if (hasStarted && mounted && _tourController.currentStop != null) {
      _centerOnStop(_toLatLng(_tourController.currentStop!.position));
    }
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
                  final normalizedNewIndex = oldIndex < newIndex
                      ? newIndex - 1
                      : newIndex;
                  _tourController.reorderUpcomingStops(
                    oldRelativeIndex: oldIndex,
                    newRelativeIndex: normalizedNewIndex,
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
      setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
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
      } catch (_) {}
    }

    final isLastStop =
        _tourController.currentStopIndex ==
        _tourController.orderedStops.length - 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PoiBottomSheet(
        stop: currentStop,
        icon: visual.icon,
        iconBackground: visual.iconBackground,
        elapsedSeconds: _tourController.elapsedSeconds,
        userXp: userXp,
        onClose: () async {
          // La tappa è modale durante il quiz: per evitare un blocco, il tasto
          // chiudi chiede conferma e termina il tour solo se l'utente conferma.
          await _confirmStopTour();
          if (mounted && !_tourController.isActive) {
            Navigator.of(context).pop();
          }
        },
        onNextStop: () async {
          // La registrazione del quiz è asincrona: il popup finale deve attendere
          // il salvataggio dell'ultima tappa per mostrare l'XP corretto.
          await _pendingQuizSave;
          if (!mounted) return;
          Navigator.pop(context);
          if (_tourController.advanceToNextStop()) {
            if (_tourController.currentStop != null) {
              _centerOnStop(_toLatLng(_tourController.currentStop!.position));
            }
          } else {
            showGeneralDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.transparent,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: TourCompletionAnimation(
                    xpGained: _tourXpEarned,
                    onDismiss: () => Navigator.of(context).pop(),
                  ),
                );
              },
            );
          }
        },
        onQuizCompleted: (result) {
          _pendingQuizSave = _registerQuizCompletion(
            currentStop.id,
            result,
            isLastStop: isLastStop,
          );
        },
      ),
    );
  }

  Future<void> _registerQuizCompletion(
    String poiId,
    QuizCompletionData result, {
    bool isLastStop = false,
  }) async {
    if (_isSavingQuizResult) return;

    final uid = _profileUseCases.getCurrentUserUid();
    if (uid == null) return;

    _isSavingQuizResult = true;

    final score = _tourScoringService.calculate(
      correctAnswers: result.score,
      legElapsedSeconds: _tourController.elapsedSeconds,
    );
    final nextTourXp = _tourXpEarned + score.totalXp;
    final nextTourCorrect = _tourCorrectAnswers + result.score;
    final nextTourQuestions = _tourTotalQuestions + result.totalQuestions;

    try {
      await _progressUseCases.registerQuizCompletion(
        uid: uid,
        poiId: poiId,
        xpGained: score.totalXp,
        correctAnswers: result.score,
        totalQuestions: result.totalQuestions,
        tourElapsedSeconds: _tourController.totalElapsedSeconds,
        isTourComplete: isLastStop,
        tourTotalXp: nextTourXp,
        tourCorrectAnswers: nextTourCorrect,
        tourTotalQuestions: nextTourQuestions,
      );
      _cachedUserXp = (_cachedUserXp ?? 0) + score.totalXp;
      _tourXpEarned = nextTourXp;
      _tourCorrectAnswers = nextTourCorrect;
      _tourTotalQuestions = nextTourQuestions;
      if (!mounted) return;
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
    } catch (_) {
      if (!mounted) return;
      showGlassSnackBar(
        context,
        message: AppLocalizations.of(context)!.errorSaveScore,
        type: GlassSnackType.error,
      );
    } finally {
      _isSavingQuizResult = false;
    }
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
