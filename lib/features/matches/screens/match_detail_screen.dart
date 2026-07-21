import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/matches/models/match_model.dart';
import 'package:sportheroes_mobile/features/matches/providers/matches_provider.dart';
import 'package:sportheroes_mobile/features/statistics/providers/statistics_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/date_formatter.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchesProvider.notifier).loadMatch(widget.matchId);
      ref.read(matchesProvider.notifier).loadTimeline(widget.matchId);
      _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        final match = ref.read(matchesProvider).currentMatch;
        if (match != null && match.isLive) {
          ref.read(matchesProvider.notifier).refreshMatch(widget.matchId);
          ref.read(matchesProvider.notifier).loadTimeline(widget.matchId);
        }
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _run(Future<bool> Function() action) async {
    final ok = await AppLoader.during(context, action, message: 'Updating…');
    if (!mounted) return;
    if (ok) {
      final msg = ref.read(matchesProvider).actionState.dataOrNull ?? 'Updated';
      AppSnackbar.success(context, msg);
      // Always re-fetch match so current set scores stay in sync after navigation.
      await ref.read(matchesProvider.notifier).loadMatch(widget.matchId);
      ref.read(matchesProvider.notifier).loadTimeline(widget.matchId);
    } else {
      final err = ref.read(matchesProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Future<void> _finishSet(MatchModel match) async {
    final current = match.currentSet;
    String? winnerSide;
    if (current != null && current.sideAScore == current.sideBScore) {
      winnerSide = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Set is tied — who wins this set?',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              ListTile(
                title: Text(match.sideLabel('A')),
                onTap: () => Navigator.pop(ctx, 'A'),
              ),
              ListTile(
                title: Text(match.sideLabel('B')),
                onTap: () => Navigator.pop(ctx, 'B'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      if (winnerSide == null) return;
    }

    if (!mounted) return;
    final ok = await AppLoader.during(
      context,
      () => ref
          .read(matchesProvider.notifier)
          .finishSet(widget.matchId, winnerSide: winnerSide),
      message: 'Finishing set…',
    );
    if (!mounted) return;
    if (ok) {
      await ref.read(matchesProvider.notifier).loadMatch(widget.matchId);
      if (!mounted) return;
      final updated = ref.read(matchesProvider).currentMatch;
      final msg =
          ref.read(matchesProvider).actionState.dataOrNull ??
          (updated?.isCompleted == true ? 'Match completed' : 'Set finished');
      AppSnackbar.success(context, msg);
      if (updated?.isCompleted == true) {
        final user = ref.read(authProvider).user;
        if (user != null) {
          ref.read(statisticsProvider.notifier).loadMyStats(user.id);
        }
      }
      ref.read(matchesProvider.notifier).loadTimeline(widget.matchId);
    } else {
      final err = ref.read(matchesProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Future<void> _completeMatch(MatchModel match) async {
    String? winnerSide = match.winnerSide;
    if (winnerSide == null) {
      final aWins = match.sets.where((s) => s.winnerSide == 'A').length;
      final bWins = match.sets.where((s) => s.winnerSide == 'B').length;
      if (aWins > bWins) {
        winnerSide = 'A';
      } else if (bWins > aWins) {
        winnerSide = 'B';
      } else {
        winnerSide = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Who won the match?',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                ListTile(
                  title: Text(match.sideLabel('A')),
                  onTap: () => Navigator.pop(ctx, 'A'),
                ),
                ListTile(
                  title: Text(match.sideLabel('B')),
                  onTap: () => Navigator.pop(ctx, 'B'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
        if (winnerSide == null) return;
      }
    }

    if (!mounted) return;

    final ok = await AppLoader.during(
      context,
      () => ref
          .read(matchesProvider.notifier)
          .complete(widget.matchId, winnerSide: winnerSide),
      message: 'Completing…',
    );
    if (!mounted) return;
    if (ok) {
      await ref.read(matchesProvider.notifier).loadMatch(widget.matchId);
      if (!mounted) return;
      final msg =
          ref.read(matchesProvider).actionState.dataOrNull ?? 'Match completed';
      AppSnackbar.success(context, msg);
      ref.read(matchesProvider.notifier).loadTimeline(widget.matchId);
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(statisticsProvider.notifier).loadMyStats(user.id);
      }
    } else {
      final err = ref.read(matchesProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchesProvider);
    final match = state.currentMatch?.id == widget.matchId
        ? state.currentMatch
        : null;
    final busy = state.actionState.isLoading;
    final timeline = state.timelineState.dataOrNull ?? const [];
    final timelineLoading = state.timelineState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Match')),
      body: ApiStateView(
        isLoading: state.detailState.isLoading && match == null,
        error: state.detailState.errorOrNull,
        onRetry: () =>
            ref.read(matchesProvider.notifier).loadMatch(widget.matchId),
        child: match == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      match.sideLabel('A'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${match.currentSet?.sideAScore ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                'vs',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      match.sideLabel('B'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${match.currentSet?.sideBScore ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (match.winnerSide != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Winner · ${match.sideLabel(match.winnerSide!)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.success700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (match.status == 'scheduled')
                    ElevatedButton(
                      onPressed: busy
                          ? null
                          : () => _run(
                              () => ref
                                  .read(matchesProvider.notifier)
                                  .start(widget.matchId),
                            ),
                      child: const Text('Start Match'),
                    ),
                  if (match.status == 'ongoing') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: busy
                                ? null
                                : () => _run(
                                    () => ref
                                        .read(matchesProvider.notifier)
                                        .recordPoint(widget.matchId, 'A'),
                                  ),
                            child: Text('+1 ${match.sideLabel('A')}'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: busy
                                ? null
                                : () => _run(
                                    () => ref
                                        .read(matchesProvider.notifier)
                                        .recordPoint(widget.matchId, 'B'),
                                  ),
                            child: Text('+1 ${match.sideLabel('B')}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: busy ? null : () => _finishSet(match),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                        ),
                        icon: const Icon(Icons.flag_rounded),
                        label: Text(
                          match.currentSet != null
                              ? 'End set ${match.currentSet!.setNumber}'
                              : 'End set',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => _run(
                                    () => ref
                                        .read(matchesProvider.notifier)
                                        .undoPoint(widget.matchId),
                                  ),
                            child: const Text('Undo'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => _run(
                                    () => ref
                                        .read(matchesProvider.notifier)
                                        .pause(widget.matchId),
                                  ),
                            child: const Text('Pause'),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => _completeMatch(match),
                            child: const Text('End Game'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (match.status == 'paused') ...[
                    ElevatedButton(
                      onPressed: busy
                          ? null
                          : () => _run(
                              () => ref
                                  .read(matchesProvider.notifier)
                                  .resume(widget.matchId),
                            ),
                      child: const Text('Resume'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: busy ? null : () => _completeMatch(match),
                      child: const Text('Force complete match'),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Sets',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (match.sets.isEmpty)
                    const Text(
                      'No sets yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  else
                    ...match.sets.map((s) {
                      final isCurrent =
                          match.currentSet?.id == s.id && s.isOpen;
                      return Card(
                        color: isCurrent
                            ? AppColors.primary50
                            : AppColors.white,
                        child: ListTile(
                          title: Text(
                            isCurrent
                                ? 'Set ${s.setNumber} · Current'
                                : 'Set ${s.setNumber}',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                          trailing: Text(
                            '${s.sideAScore} - ${s.sideBScore}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: s.winnerSide != null
                              ? Text(
                                  'Winner: ${match.sideLabel(s.winnerSide!)}',
                                )
                              : Text(isCurrent ? 'Scoring now' : 'In progress'),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Point history',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (timelineLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          tooltip: 'Refresh',
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          onPressed: () => ref
                              .read(matchesProvider.notifier)
                              .loadTimeline(widget.matchId),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (state.timelineState.isError)
                    Text(
                      state.timelineState.errorOrNull ??
                          'Failed to load timeline',
                      style: const TextStyle(color: AppColors.error),
                    )
                  else if (timelineLoading && timeline.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: AppLogoLoader(
                          size: 40,
                          message: 'Loading points…',
                        ),
                      ),
                    )
                  else if (timeline.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No points recorded yet. Score points to build the timeline.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...timeline.reversed.map((p) {
                      final undone = p.isUndone;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: undone
                                ? AppColors.grey200
                                : AppColors.primary100,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: undone
                                  ? AppColors.grey100
                                  : AppColors.primary50,
                              child: Text(
                                '${p.pointNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: undone
                                      ? AppColors.grey500
                                      : AppColors.primary,
                                  decoration: undone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    undone
                                        ? 'Point undone · ${match.sideLabel(p.scoringSide)}'
                                        : 'Point to ${match.sideLabel(p.scoringSide)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: undone
                                          ? AppColors.textTertiary
                                          : AppColors.textPrimary,
                                      decoration: undone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    'Score ${p.sideAScoreAfter}-${p.sideBScoreAfter}'
                                    '${p.recordedAt != null ? ' · ${DateFormatter.formatToDateTimeSeconds(p.recordedAt!)}' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              undone
                                  ? Icons.undo_rounded
                                  : Icons.sports_score_rounded,
                              color: undone
                                  ? AppColors.grey400
                                  : AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
      ),
    );
  }
}
