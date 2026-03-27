// Poker Sharp — Drill Screen (Full Implementation)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/poker.dart';
import '../../../core/scoring.dart';
import '../../../core/game_state.dart';
import '../../../core/providers.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../../tokens/stroke_tokens.dart';
import '../../tokens/motion_tokens.dart';
import 'board_display.dart';
import 'poker_card_widget.dart';
import 'two_step_picker.dart';
import 'full_grid_picker.dart';
import 'holdings_list.dart';

class DrillScreen extends ConsumerStatefulWidget {
  const DrillScreen({super.key});

  @override
  ConsumerState<DrillScreen> createState() => _DrillScreenState();
}

class _DrillScreenState extends ConsumerState<DrillScreen> {
  Card? _firstCard; // first card of a holding pair
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    // Start the timer if enabled
    final config = ref.read(drillConfigProvider);
    if (config.timerEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timerProvider.notifier).start();
      });
    }
  }

  /// Per spec §2.4: ONLY board cards are excluded from selection.
  /// Cards used in existing holdings remain fully available.
  /// The first card of an in-progress holding is also excluded
  /// (so user can't pick the same card twice in one holding).
  Set<int> get _usedCardKeys {
    final board = ref.read(currentBoardProvider) ?? [];
    final keys = <int>{};
    for (final c in board) {
      keys.add(cardKey(c));
    }
    if (_firstCard != null) {
      keys.add(cardKey(_firstCard!));
    }
    return keys;
  }

  void _onCardPicked(Card card) {
    if (_firstCard == null) {
      setState(() => _firstCard = card);
    } else {
      final holding = [_firstCard!, card];
      // Sort the holding: higher rank first
      holding.sort((a, b) {
        if (a.rank != b.rank) return b.rank - a.rank;
        return a.suit - b.suit;
      });

      final board = ref.read(currentBoardProvider) ?? [];
      final classes = ref.read(equivalenceClassesProvider);
      final holdings = ref.read(currentHoldingsProvider);
      final config = ref.read(drillConfigProvider);

      // Check for duplicate equivalence class
      final newClass =
          findEquivalenceClassForHolding(holding, board, classes);

      if (newClass != null) {
        // Check if any existing holding is already in this class
        for (final existing in holdings) {
          final existingClass =
              findEquivalenceClassForHolding(existing, board, classes);
          if (existingClass != null &&
              existingClass.rank == newClass.rank) {
            // Duplicate class — block it
            setState(() => _firstCard = null);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Already have a holding in class #${newClass.rank} '
                    '(${newClass.label})',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            return;
          }
        }
      }

      // Show multi-member toast if class has multiple members
      if (newClass != null && newClass.memberCount > 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${newClass.label}: ${newClass.memberCount} holdings in '
                'this class',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      ref.read(currentHoldingsProvider.notifier).add(holding);
      setState(() => _firstCard = null);
    }
  }

  void _handleUndo() {
    final notifier = ref.read(currentHoldingsProvider.notifier);
    if (notifier.canUndo) {
      notifier.undo();
      setState(() => _firstCard = null);
    }
  }

  void _handleClear() {
    final holdings = ref.read(currentHoldingsProvider);
    if (holdings.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all holdings?'),
        content: Text(
          'This will remove all ${holdings.length} holdings from your list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentHoldingsProvider.notifier).clear();
              setState(() => _firstCard = null);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _handleLeave() {
    final holdings = ref.read(currentHoldingsProvider);
    if (holdings.isEmpty) {
      _doLeave();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave drill?'),
        content: const Text(
          'Your progress will be lost. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _doLeave();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _doLeave() {
    ref.read(timerProvider.notifier).stop();
    ref.read(currentHoldingsProvider.notifier).clear();
    context.go('/');
  }

  void _handleSubmit() {
    final board = ref.read(currentBoardProvider);
    if (board == null) return;

    final holdings = ref.read(currentHoldingsProvider);
    final config = ref.read(drillConfigProvider);
    final timerMs = ref.read(timerProvider);

    // Show confirmation if fewer than target count
    if (holdings.length < config.holdingsCount) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submit early?'),
          content: Text(
            'You\'ve ranked ${holdings.length} of '
            '${config.holdingsCount} holdings. Submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Going'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _doSubmit();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
      return;
    }

    _doSubmit();
  }

  void _doSubmit() {
    final board = ref.read(currentBoardProvider);
    if (board == null) return;

    final holdings = ref.read(currentHoldingsProvider);
    final config = ref.read(drillConfigProvider);
    final timerMs = ref.read(timerProvider);

    // Stop timer
    ref.read(timerProvider.notifier).stop();

    // Score submission
    final userHoldings =
        holdings.map((h) => (cards: h)).toList();
    final scoringResult =
        scoreSubmissionGrouped(board, userHoldings, config.holdingsCount);

    // Analyze board texture
    final boardTexture = analyzeBoardTexture(board);

    // Save result for results screen
    ref.read(lastResultProvider.notifier).state = LastResultState(
      board: board,
      scoringResult: scoringResult,
      timeTakenMs: config.timerEnabled ? timerMs : null,
      targetCount: config.holdingsCount,
      hintUsed: _showHint,
    );

    // Save drill record
    final record = DrillRecord(
      id: generateId(),
      date: DateTime.now(),
      board: board,
      targetCount: config.holdingsCount,
      pickerMode: config.pickerMode,
      timerEnabled: config.timerEnabled,
      timeTakenMs: config.timerEnabled ? timerMs : null,
      hintUsed: _showHint,
      userHoldings: holdings
          .asMap()
          .entries
          .map((e) => (cards: e.value, rank: e.key + 1))
          .toList(),
      scoringResult: scoringResult,
      boardTexture: boardTexture,
      suitSensitive: isBoardSuitSensitive(board),
    );
    ref.read(drillHistoryProvider.notifier).addDrill(record);

    // Navigate to results
    context.go('/results');
  }

  void _handleToggleHint() {
    setState(() => _showHint = !_showHint);
  }

  String _formatTimer(int ms) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final tenths = (ms % 1000) ~/ 100;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final board = ref.watch(currentBoardProvider) ?? [];
    final holdings = ref.watch(currentHoldingsProvider);
    final config = ref.watch(drillConfigProvider);
    final timerMs = ref.watch(timerProvider);
    final classes = ref.watch(equivalenceClassesProvider);
    final canUndo = ref.watch(currentHoldingsProvider.notifier).canUndo;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleLeave();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              _TopBar(
                timerEnabled: config.timerEnabled,
                timerMs: timerMs,
                formatTimer: _formatTimer,
                canUndo: canUndo,
                onBack: _handleLeave,
                onUndo: _handleUndo,
                onClear: _handleClear,
                onHint: _handleToggleHint,
                showHint: _showHint,
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.xxl,
                  ),
                  children: [
                    // Board display
                    if (board.isNotEmpty)
                      BoardDisplay(board: board),
                    const SizedBox(height: AppSpace.lg),

                    // Hint: show equivalence class labels
                    if (_showHint && classes.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpace.md),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.all(AppRadius.sm),
                          border: Border.all(
                            color:
                                colorScheme.secondary.withValues(alpha: 0.3),
                            width: AppStroke.thin,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    size: 14, color: colorScheme.secondary),
                                const SizedBox(width: AppSpace.xs),
                                Text(
                                  'Hint: Top ${config.holdingsCount} Classes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpace.sm),
                            Wrap(
                              spacing: AppSpace.xs,
                              runSpacing: AppSpace.xs,
                              children: classes.map((c) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpace.sm,
                                    vertical: AppSpace.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius:
                                        BorderRadius.all(AppRadius.xs),
                                  ),
                                  child: Text(
                                    '#${c.rank} ${c.label}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.lg),
                    ],

                    // Progress indicator
                    Row(
                      children: [
                        Text(
                          '${holdings.length} / ${config.holdingsCount}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Text(
                          'holdings',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const Spacer(),
                        if (_firstCard != null)
                          Row(
                            children: [
                              Text(
                                'First card: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              CardChip(card: _firstCard!),
                              const SizedBox(width: AppSpace.xs),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _firstCard = null),
                                child: Icon(Icons.close,
                                    size: 14,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.4)),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.sm),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.all(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: holdings.length / config.holdingsCount,
                        backgroundColor:
                            colorScheme.surfaceContainerHigh,
                        color: holdings.length >= config.holdingsCount
                            ? const Color(0xFF4CAF50)
                            : colorScheme.primary,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),

                    // Card Picker
                    if (config.pickerMode == PickerMode.twoStep)
                      TwoStepPicker(
                        usedCardKeys: _usedCardKeys,
                        onCardPicked: _onCardPicked,
                      )
                    else
                      FullGridPicker(
                        usedCardKeys: _usedCardKeys,
                        onCardPicked: _onCardPicked,
                      ),
                    const SizedBox(height: AppSpace.lg),

                    // Holdings list
                    HoldingsList(
                      holdings: holdings,
                      targetCount: config.holdingsCount,
                      onRemove: (index) {
                        ref
                            .read(currentHoldingsProvider.notifier)
                            .removeAt(index);
                      },
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(currentHoldingsProvider.notifier)
                            .reorder(oldIndex, newIndex);
                      },
                    ),
                    const SizedBox(height: AppSpace.lg),

                    // Submit button
                    if (holdings.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _handleSubmit,
                          icon: const Icon(Icons.check, size: 20),
                          label: Text(
                            holdings.length >= config.holdingsCount
                                ? 'Submit'
                                : 'Submit (${holdings.length}/${config.holdingsCount})',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                holdings.length >= config.holdingsCount
                                    ? const Color(0xFF4CAF50)
                                    : colorScheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool timerEnabled;
  final int timerMs;
  final String Function(int) formatTimer;
  final bool canUndo;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onHint;
  final bool showHint;

  const _TopBar({
    required this.timerEnabled,
    required this.timerMs,
    required this.formatTimer,
    required this.canUndo,
    required this.onBack,
    required this.onUndo,
    required this.onClear,
    required this.onHint,
    required this.showHint,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: onBack,
            tooltip: 'Leave drill',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),

          // Timer
          if (timerEnabled) ...[
            const SizedBox(width: AppSpace.sm),
            Icon(Icons.timer, size: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: AppSpace.xs),
            Text(
              formatTimer(timerMs),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],

          const Spacer(),

          // Hint button
          IconButton(
            icon: Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: showHint
                  ? colorScheme.secondary
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onPressed: onHint,
            tooltip: 'Toggle hint',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),

          // Undo button
          IconButton(
            icon: Icon(
              Icons.undo,
              size: 20,
              color: canUndo
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            onPressed: canUndo ? onUndo : null,
            tooltip: 'Undo',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),

          // Clear button
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.5)),
            onPressed: onClear,
            tooltip: 'Clear all',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
