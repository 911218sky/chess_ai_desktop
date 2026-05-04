import 'dart:math' as math;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/game_controller.dart';
import 'i18n/app_localizations.dart';
import 'models/bot_roster.dart';
import 'models/engine_models.dart';
import 'models/game_state.dart';
import 'models/session_config.dart';
import 'theme/app_theme.dart';
import 'theme/board_theme.dart';
import 'utils/text_sanitizer.dart';
import 'widgets/bot_visuals.dart';
import 'widgets/chess_board.dart';
import 'widgets/control_panel.dart';
import 'widgets/typewriter_text.dart';

String? _resultKeyForState(GameState state) {
  if (!state.isGameOver) {
    return null;
  }
  final timeout = state.timeoutWinner?.name ?? 'none';
  final outcome = state.outcome?.winner?.name ?? 'draw';
  return '${state.position.fen}|$timeout|$outcome';
}

GameResultDisplay? _resultDisplayForState(GameState state) {
  if (!state.isGameOver) {
    return null;
  }
  if (state.timeoutWinner case final winner?) {
    return winner == state.config.playerSide
        ? GameResultDisplay.win
        : GameResultDisplay.lose;
  }
  final outcome = state.outcome;
  if (outcome == null) {
    return null;
  }
  if (outcome.winner == null) {
    return GameResultDisplay.draw;
  }
  return outcome.winner == state.config.playerSide
      ? GameResultDisplay.win
      : GameResultDisplay.lose;
}

Side? _losingSideForState(GameState state) {
  if (!state.isGameOver) {
    return null;
  }
  if (state.timeoutWinner case final winner?) {
    return winner == Side.white ? Side.black : Side.white;
  }
  final outcome = state.outcome;
  if (outcome == null) {
    return null;
  }
  if (outcome.winner == null) {
    return null;
  }
  return outcome.winner == Side.white ? Side.black : Side.white;
}

class ChessAIDesktopApp extends ConsumerWidget {
  const ChessAIDesktopApp({super.key, this.autoInitialize = true});

  final bool autoInitialize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryFocus,
      brightness: Brightness.dark,
    );
    final appTextScalePercent = ref.watch(
      gameControllerProvider.select(
        (state) => state.config.appTextScalePercent,
      ),
    );

    return MaterialApp(
      title: 'Chess AI Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: ThemeData.dark(useMaterial3: true).textTheme.apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.field,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: const BorderSide(color: Color(0xFF3B403D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: const BorderSide(
              color: AppColors.primaryFocus,
              width: 1.5,
            ),
          ),
        ),
        dividerColor: Colors.white10,
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1E8),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                color: Color(0x33000000),
                offset: Offset(0, 10),
              ),
            ],
          ),
          textStyle: const TextStyle(
            color: Color(0xFF2A2A26),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: EdgeInsets.all(10),
          preferBelow: false,
          waitDuration: Duration(milliseconds: 250),
        ),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(appTextScalePercent / 100),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: ChessHomePage(autoInitialize: autoInitialize),
    );
  }
}

class ChessHomePage extends ConsumerStatefulWidget {
  const ChessHomePage({super.key, this.autoInitialize = true});

  final bool autoInitialize;

  @override
  ConsumerState<ChessHomePage> createState() => _ChessHomePageState();
}

class _ChessHomePageState extends ConsumerState<ChessHomePage> {
  Future<void> _openAiPanelDialog(
    GameState state,
    GameController controller,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (dialogContext) {
        final dialogSize = MediaQuery.sizeOf(dialogContext);
        final panelWidth = dialogSize.width >= 1500
            ? 980.0
            : dialogSize.width >= 1200
            ? 860.0
            : dialogSize.width * 0.94;
        final panelHeight = dialogSize.height * 0.88;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: panelWidth,
              maxHeight: panelHeight,
            ),
            child: ControlPanel(
              state: state,
              onDifficultyChanged: controller.updateDifficulty,
              onOpponentDepthChanged: controller.updateOpponentDepth,
              onTeacherDepthChanged: controller.updateTeacherDepth,
              onEngineResourcesChanged: controller.updateEngineResources,
              onTimeControlChanged: controller.updateTimeControl,
              onPlayerSideChanged: controller.updatePlayerSide,
              onHintModeChanged: controller.updateHintMode,
              onCandidateLineCountChanged: controller.updateCandidateLineCount,
              onAppTextScalePercentChanged:
                  controller.updateAppTextScalePercent,
              onOpenAiPanelPressed: () => Navigator.of(dialogContext).pop(),
              onBoardThemeChanged: controller.updateBoardTheme,
              onLocaleChanged: controller.updateLocale,
              onPersonaChanged: controller.updatePersona,
              onCoachPersonaChanged: controller.updateCoachPersona,
              onTauntLevelChanged: controller.updateTauntLevel,
              onNewGamePressed: controller.startNewGame,
              onRematchPressed: controller.rematch,
              onLlmEnabledChanged: controller.updateLlmEnabled,
              onLlmProviderChanged: controller.updateLlmProvider,
              onLlmBaseUrlChanged: controller.updateLlmBaseUrl,
              onLlmModelChanged: controller.updateLlmModel,
              onLlmApiKeyChanged: controller.updateLlmApiKey,
              onLlmIdleBanterEnabledChanged:
                  controller.updateLlmIdleBanterEnabled,
              onLlmIdleBanterMinSecondsChanged:
                  controller.updateLlmIdleBanterMinSeconds,
              onLlmIdleBanterMaxSecondsChanged:
                  controller.updateLlmIdleBanterMaxSeconds,
              onResetLlmStatsPressed: controller.resetLlmUsageStats,
              onTestLlmPressed: controller.testLlmConnection,
              onFetchLlmModelsPressed: controller.fetchLlmModels,
              onResetLlmPressed: controller.resetLlmSettings,
              onResetPreferencesPressed: controller.resetPreferences,
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoInitialize) {
      Future.microtask(
        () => ref.read(gameControllerProvider.notifier).initialize(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1320;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: Stack(
          children: [
            const Positioned.fill(child: _ArenaBackdropConnector()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                child: Column(
                  children: [
                    Expanded(
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const _TopBar(),
                                      const SizedBox(height: 8),
                                      const Expanded(child: _BoardConnector()),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: 460,
                                  child: _ControlPanelConnector(
                                    onOpenAiPanelPressed:
                                        _openAiPanelDialogFromCurrentState,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const _TopBar(),
                                const SizedBox(height: 8),
                                const Expanded(
                                  flex: 7,
                                  child: _BoardConnector(),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  flex: 6,
                                  child: _ControlPanelConnector(
                                    onOpenAiPanelPressed:
                                        _openAiPanelDialogFromCurrentState,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAiPanelDialogFromCurrentState() {
    return _openAiPanelDialog(
      ref.read(gameControllerProvider),
      ref.read(gameControllerProvider.notifier),
    );
  }
}

class _ArenaBackdropConnector extends ConsumerWidget {
  const _ArenaBackdropConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeId = ref.watch(
      gameControllerProvider.select((state) => state.config.boardTheme),
    );
    return _ArenaBackdrop(themeId: themeId);
  }
}

class _BoardConnector extends ConsumerWidget {
  const _BoardConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _BoardWorkspace();
  }
}

class _ControlPanelConnector extends ConsumerWidget {
  const _ControlPanelConnector({required this.onOpenAiPanelPressed});

  final VoidCallback onOpenAiPanelPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      gameControllerProvider.select(ControlPanelViewState.fromGameState),
    );
    final controller = ref.read(gameControllerProvider.notifier);
    return ControlPanel(
      state: state.toGameState(),
      onDifficultyChanged: controller.updateDifficulty,
      onOpponentDepthChanged: controller.updateOpponentDepth,
      onTeacherDepthChanged: controller.updateTeacherDepth,
      onEngineResourcesChanged: controller.updateEngineResources,
      onTimeControlChanged: controller.updateTimeControl,
      onPlayerSideChanged: controller.updatePlayerSide,
      onHintModeChanged: controller.updateHintMode,
      onCandidateLineCountChanged: controller.updateCandidateLineCount,
      onAppTextScalePercentChanged: controller.updateAppTextScalePercent,
      onOpenAiPanelPressed: onOpenAiPanelPressed,
      onBoardThemeChanged: controller.updateBoardTheme,
      onLocaleChanged: controller.updateLocale,
      onPersonaChanged: controller.updatePersona,
      onCoachPersonaChanged: controller.updateCoachPersona,
      onTauntLevelChanged: controller.updateTauntLevel,
      onNewGamePressed: controller.startNewGame,
      onRematchPressed: controller.rematch,
      onLlmEnabledChanged: controller.updateLlmEnabled,
      onLlmProviderChanged: controller.updateLlmProvider,
      onLlmBaseUrlChanged: controller.updateLlmBaseUrl,
      onLlmModelChanged: controller.updateLlmModel,
      onLlmApiKeyChanged: controller.updateLlmApiKey,
      onLlmIdleBanterEnabledChanged: controller.updateLlmIdleBanterEnabled,
      onLlmIdleBanterMinSecondsChanged:
          controller.updateLlmIdleBanterMinSeconds,
      onLlmIdleBanterMaxSecondsChanged:
          controller.updateLlmIdleBanterMaxSeconds,
      onResetLlmStatsPressed: controller.resetLlmUsageStats,
      onTestLlmPressed: controller.testLlmConnection,
      onFetchLlmModelsPressed: controller.fetchLlmModels,
      onResetLlmPressed: controller.resetLlmSettings,
      onResetPreferencesPressed: controller.resetPreferences,
    );
  }
}

class _ArenaBackdrop extends StatelessWidget {
  const _ArenaBackdrop({required this.themeId});

  final BoardThemeId themeId;

  @override
  Widget build(BuildContext context) {
    final theme = boardThemeStyle(themeId);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.backdropTop, theme.backdropBottom],
              ),
            ),
          ),
        ),
        if (theme.backdropAsset != null)
          Positioned.fill(
            child: Image.asset(
              theme.backdropAsset!,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.58),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.30, -0.30),
                radius: 1.15,
                colors: [
                  theme.backdropAccent.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.backdropShadow.withValues(alpha: 0.10),
                  theme.backdropShadow.withValues(alpha: 0.58),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -120,
          top: 64,
          child: Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 520,
              height: 180,
              decoration: BoxDecoration(
                color: theme.backdropAccent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        Positioned(
          right: -70,
          bottom: 110,
          child: Transform.rotate(
            angle: 0.08,
            child: Container(
              width: 420,
              height: 160,
              decoration: BoxDecoration(
                color: theme.panelTint.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(children: const [Spacer()]);
  }
}

class _BoardWorkspace extends StatelessWidget {
  static const double _dialogueRailHeight = 148;
  static const double _dialogueRailSpacing = 6;
  static const double _minWorkspaceHeight = 360;

  const _BoardWorkspace();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = SizedBox(
            height: math.max(constraints.maxHeight, _minWorkspaceHeight),
            child: const _BoardWorkspaceBody(),
          );
          if (constraints.maxHeight < _minWorkspaceHeight) {
            return SingleChildScrollView(child: content);
          }
          return content;
        },
      ),
    );
  }
}

class _BoardWorkspaceBody extends StatelessWidget {
  const _BoardWorkspaceBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: _BoardWorkspace._dialogueRailHeight,
          child: _DialogueConnector(),
        ),
        const SizedBox(height: _BoardWorkspace._dialogueRailSpacing),
        Expanded(
          child: LayoutBuilder(
            builder: (context, boardAreaConstraints) {
              final boardHeightBudget = boardAreaConstraints.maxHeight;

              return Center(
                child: _BoardWithClocksConnector(
                  availableHeight: math.max(120, boardHeightBudget),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DialogueViewState {
  const _DialogueViewState({
    required this.opponentIcon,
    required this.opponentTone,
    required this.opponentName,
    required this.opponentMessage,
    required this.opponentMessageSource,
    required this.coachName,
    required this.coachMessage,
    required this.coachMessageSource,
    required this.aiThinking,
    required this.llmStatusMessage,
    required this.llmError,
    required this.textScale,
    required this.locale,
  });

  final IconData opponentIcon;
  final Color opponentTone;
  final String opponentName;
  final String opponentMessage;
  final DialogueMessageSource opponentMessageSource;
  final String coachName;
  final String coachMessage;
  final DialogueMessageSource coachMessageSource;
  final bool aiThinking;
  final String? llmStatusMessage;
  final String? llmError;
  final double textScale;
  final AppLocale locale;

  @override
  bool operator ==(Object other) {
    return other is _DialogueViewState &&
        other.opponentIcon == opponentIcon &&
        other.opponentTone == opponentTone &&
        other.opponentName == opponentName &&
        other.opponentMessage == opponentMessage &&
        other.opponentMessageSource == opponentMessageSource &&
        other.coachName == coachName &&
        other.coachMessage == coachMessage &&
        other.coachMessageSource == coachMessageSource &&
        other.aiThinking == aiThinking &&
        other.llmStatusMessage == llmStatusMessage &&
        other.llmError == llmError &&
        other.textScale == textScale &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(
    opponentIcon,
    opponentTone,
    opponentName,
    opponentMessage,
    opponentMessageSource,
    coachName,
    coachMessage,
    coachMessageSource,
    aiThinking,
    llmStatusMessage,
    llmError,
    textScale,
    locale,
  );
}

class _DialogueConnector extends ConsumerWidget {
  const _DialogueConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(
      gameControllerProvider.select((state) {
        final profile = profileForConfig(state.config);
        final strings = AppStrings.of(state.config.locale);
        return _DialogueViewState(
          opponentIcon: botProfileIcon(profile),
          opponentTone: botProfileTone(profile),
          opponentName: profile.name,
          opponentMessage: state.opponentMessage,
          opponentMessageSource: state.opponentMessageSource,
          coachName: state.config.coachPersona.localizedLabel(strings),
          coachMessage: state.coachMessage,
          coachMessageSource: state.coachMessageSource,
          aiThinking: state.aiThinking,
          llmStatusMessage: state.llmStatusMessage,
          llmError: state.lastLlmError,
          textScale: state.config.appTextScalePercent / 100,
          locale: state.config.locale,
        );
      }),
    );

    return _DialogueRail(
      opponentIcon: viewState.opponentIcon,
      opponentTone: viewState.opponentTone,
      opponentName: viewState.opponentName,
      opponentMessage: viewState.opponentMessage,
      opponentMessageSource: viewState.opponentMessageSource,
      coachName: viewState.coachName,
      coachMessage: viewState.coachMessage,
      coachMessageSource: viewState.coachMessageSource,
      aiThinking: viewState.aiThinking,
      llmStatusMessage: viewState.llmStatusMessage,
      llmError: viewState.llmError,
      textScale: viewState.textScale,
    );
  }
}

class _BoardWithClocksViewState {
  const _BoardWithClocksViewState({
    required this.locale,
    required this.playerSide,
    required this.turn,
    required this.isGameOver,
    required this.whiteClockMs,
    required this.blackClockMs,
    required this.statusText,
    required this.hardwareProfile,
    required this.engineResources,
    required this.opponentDepth,
    required this.teacherDepth,
    required this.opponentAnalysis,
    required this.hint,
    required this.profile,
  });

  final AppLocale locale;
  final Side playerSide;
  final Side turn;
  final bool isGameOver;
  final int? whiteClockMs;
  final int? blackClockMs;
  final String statusText;
  final EngineHardwareProfile? hardwareProfile;
  final EngineResourceSettings engineResources;
  final SearchDepthLevel opponentDepth;
  final SearchDepthLevel teacherDepth;
  final EngineAnalysis? opponentAnalysis;
  final EngineAnalysis? hint;
  final BotProfile profile;

  @override
  bool operator ==(Object other) {
    return other is _BoardWithClocksViewState &&
        other.locale == locale &&
        other.playerSide == playerSide &&
        other.turn == turn &&
        other.isGameOver == isGameOver &&
        other.whiteClockMs == whiteClockMs &&
        other.blackClockMs == blackClockMs &&
        other.statusText == statusText &&
        _sameHardwareProfile(other.hardwareProfile, hardwareProfile) &&
        _sameEngineResources(other.engineResources, engineResources) &&
        other.opponentDepth == opponentDepth &&
        other.teacherDepth == teacherDepth &&
        other.opponentAnalysis == opponentAnalysis &&
        other.hint == hint &&
        _sameBotProfile(other.profile, profile);
  }

  @override
  int get hashCode => Object.hash(
    locale,
    playerSide,
    turn,
    isGameOver,
    whiteClockMs,
    blackClockMs,
    statusText,
    _hardwareProfileHash(hardwareProfile),
    Object.hash(
      engineResources.auto,
      engineResources.threads,
      engineResources.hashMb,
    ),
    opponentDepth,
    teacherDepth,
    opponentAnalysis,
    hint,
    profile,
  );
}

bool _sameHardwareProfile(EngineHardwareProfile? a, EngineHardwareProfile? b) {
  return a?.cpuThreads == b?.cpuThreads &&
      a?.memoryMb == b?.memoryMb &&
      a?.recommendedThreads == b?.recommendedThreads &&
      a?.recommendedHashMb == b?.recommendedHashMb;
}

int _hardwareProfileHash(EngineHardwareProfile? profile) {
  return Object.hash(
    profile?.cpuThreads,
    profile?.memoryMb,
    profile?.recommendedThreads,
    profile?.recommendedHashMb,
  );
}

bool _sameEngineResources(EngineResourceSettings a, EngineResourceSettings b) {
  return a.auto == b.auto && a.threads == b.threads && a.hashMb == b.hashMb;
}

bool _sameBotProfile(BotProfile a, BotProfile b) {
  return a.name == b.name &&
      a.rating == b.rating &&
      a.category == b.category &&
      a.persona == b.persona &&
      a.difficulty == b.difficulty &&
      a.tauntLevel == b.tauntLevel;
}

class _BoardWithClocksConnector extends ConsumerWidget {
  const _BoardWithClocksConnector({required this.availableHeight});

  final double availableHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(
      gameControllerProvider.select(
        (state) => _BoardWithClocksViewState(
          locale: state.config.locale,
          playerSide: state.config.playerSide,
          turn: state.position.turn,
          isGameOver: state.isGameOver,
          whiteClockMs: state.whiteClockMs,
          blackClockMs: state.blackClockMs,
          statusText: state.statusText,
          hardwareProfile: state.hardwareProfile,
          engineResources: state.config.engineResources,
          opponentDepth: state.config.opponentDepth,
          teacherDepth: state.config.teacherDepth,
          opponentAnalysis: state.opponentAnalysis,
          hint: state.hint,
          profile: profileForConfig(state.config),
        ),
      ),
    );
    final strings = AppStrings.of(viewState.locale);

    return _BoardWithClocks(
      viewState: viewState,
      strings: strings,
      availableHeight: availableHeight,
      opponentName: viewState.profile.name,
      opponentSubtitle:
          '${viewState.profile.rating}  ${viewState.profile.localizedCategory(strings)}',
      opponentTone: botProfileTone(viewState.profile),
      opponentIcon: botProfileIcon(viewState.profile),
      playerName: strings.guest,
      playerSubtitle: viewState.statusText,
      playerTone: const Color(0xFF5F88FF),
      playerIcon: Icons.person_rounded,
      child: const _ChessBoardConnector(),
    );
  }
}

class _ChessBoardViewState {
  const _ChessBoardViewState({
    required this.position,
    required this.orientation,
    required this.selectedSquare,
    required this.legalTargets,
    required this.lastMove,
    required this.hintLines,
    required this.themeId,
    required this.resultKey,
    required this.resultDisplay,
    required this.losingSide,
  });

  final Position position;
  final Side orientation;
  final Square? selectedSquare;
  final Set<Square> legalTargets;
  final LastMove? lastMove;
  final List<EngineLine> hintLines;
  final BoardThemeId themeId;
  final String? resultKey;
  final GameResultDisplay? resultDisplay;
  final Side? losingSide;

  @override
  bool operator ==(Object other) {
    return other is _ChessBoardViewState &&
        other.position == position &&
        other.orientation == orientation &&
        other.selectedSquare == selectedSquare &&
        setEquals(other.legalTargets, legalTargets) &&
        other.lastMove == lastMove &&
        listEquals(other.hintLines, hintLines) &&
        other.themeId == themeId &&
        other.resultKey == resultKey &&
        other.resultDisplay == resultDisplay &&
        other.losingSide == losingSide;
  }

  @override
  int get hashCode => Object.hash(
    position,
    orientation,
    selectedSquare,
    Object.hashAllUnordered(legalTargets),
    lastMove,
    Object.hashAll(hintLines),
    themeId,
    resultKey,
    resultDisplay,
    losingSide,
  );
}

class _ChessBoardConnector extends ConsumerWidget {
  const _ChessBoardConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(
      gameControllerProvider.select(
        (state) => _ChessBoardViewState(
          position: state.position,
          orientation: state.config.playerSide,
          selectedSquare: state.selectedSquare,
          legalTargets: state.legalTargets,
          lastMove: state.lastMove,
          hintLines: state.hint?.lines ?? const [],
          themeId: state.config.boardTheme,
          resultKey: _resultKeyForState(state),
          resultDisplay: _resultDisplayForState(state),
          losingSide: _losingSideForState(state),
        ),
      ),
    );
    final controller = ref.read(gameControllerProvider.notifier);

    return ChessBoard(
      position: boardState.position,
      orientation: boardState.orientation,
      selectedSquare: boardState.selectedSquare,
      legalTargets: boardState.legalTargets,
      lastMove: boardState.lastMove,
      hintLines: boardState.hintLines,
      themeId: boardState.themeId,
      resultKey: boardState.resultKey,
      resultDisplay: boardState.resultDisplay,
      losingSide: boardState.losingSide,
      onSquareTap: controller.tapSquare,
      onMoveDropped: controller.dropMove,
    );
  }
}

class _BoardWithClocks extends StatelessWidget {
  const _BoardWithClocks({
    required this.viewState,
    required this.strings,
    required this.availableHeight,
    required this.opponentName,
    required this.opponentSubtitle,
    required this.opponentTone,
    required this.opponentIcon,
    required this.playerName,
    required this.playerSubtitle,
    required this.playerTone,
    required this.playerIcon,
    required this.child,
  });

  final _BoardWithClocksViewState viewState;
  final AppStrings strings;
  final double availableHeight;
  final String opponentName;
  final String opponentSubtitle;
  final Color opponentTone;
  final IconData opponentIcon;
  final String playerName;
  final String playerSubtitle;
  final Color playerTone;
  final IconData playerIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final topSide = viewState.playerSide == Side.white
        ? Side.black
        : Side.white;
    final bottomSide = viewState.playerSide;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final topIdentity = _SideIdentityCard(
          name: opponentName,
          subtitle: opponentSubtitle,
          tone: opponentTone,
          icon: opponentIcon,
        );
        final bottomIdentity = _SideIdentityCard(
          name: playerName,
          subtitle: playerSubtitle,
          tone: playerTone,
          icon: playerIcon,
        );
        final topClock = _BoardClock(
          label: topSide == Side.white ? strings.white : strings.black,
          milliseconds: _clockFor(topSide),
          active: viewState.turn == topSide && !viewState.isGameOver,
          tone: topSide == Side.white
              ? const Color(0xFFF2E9D8)
              : const Color(0xFF8B9290),
        );
        final bottomClock = _BoardClock(
          label: bottomSide == Side.white ? strings.white : strings.black,
          milliseconds: _clockFor(bottomSide),
          active: viewState.turn == bottomSide && !viewState.isGameOver,
          tone: bottomSide == Side.white
              ? const Color(0xFFF2E9D8)
              : const Color(0xFF8B9290),
        );

        if (compact) {
          const sideCardHeight = 66.0;
          const clockHeight = 72.0;
          const verticalGap = 6.0;
          final heightBudget = math.min(availableHeight, constraints.maxHeight);
          final boardHeight =
              heightBudget -
              (sideCardHeight * 2) -
              (clockHeight * 2) -
              (verticalGap * 4);
          final boardSize = math.max<double>(
            120,
            math.min<double>(constraints.maxWidth, boardHeight),
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: boardSize, child: topIdentity),
              const SizedBox(height: 6),
              SizedBox(width: boardSize, child: topClock),
              const SizedBox(height: 6),
              SizedBox(width: boardSize, height: boardSize, child: child),
              const SizedBox(height: 6),
              SizedBox(width: boardSize, child: bottomClock),
              const SizedBox(height: 6),
              SizedBox(width: boardSize, child: bottomIdentity),
            ],
          );
        }

        const identityColumnWidth = 140.0;
        const boardGap = 12.0;
        final boardWidthBudget =
            constraints.maxWidth - identityColumnWidth - boardGap;
        final boardHeightBudget = math.min(
          availableHeight,
          constraints.maxHeight,
        );
        final boardSize = math.max<double>(
          120,
          math.min<double>(boardWidthBudget, boardHeightBudget),
        );
        final denseSideColumn = boardSize < 320;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: identityColumnWidth,
              height: boardSize,
              child: Column(
                children: [
                  _EngineInfoHoverCard(
                    viewState: viewState,
                    side: topSide,
                    identity: topIdentity,
                    clock: topClock,
                    strings: strings,
                    dense: denseSideColumn,
                  ),
                  const Spacer(),
                  _EngineInfoHoverCard(
                    viewState: viewState,
                    side: bottomSide,
                    identity: bottomIdentity,
                    clock: bottomClock,
                    strings: strings,
                    dense: denseSideColumn,
                  ),
                ],
              ),
            ),
            const SizedBox(width: boardGap),
            SizedBox(width: boardSize, height: boardSize, child: child),
          ],
        );
      },
    );
  }

  int? _clockFor(Side side) {
    return side == Side.white ? viewState.whiteClockMs : viewState.blackClockMs;
  }
}

class _EngineInfoHoverCard extends StatelessWidget {
  const _EngineInfoHoverCard({
    required this.viewState,
    required this.side,
    required this.identity,
    required this.clock,
    required this.strings,
    required this.dense,
  });

  final _BoardWithClocksViewState viewState;
  final Side side;
  final Widget identity;
  final Widget clock;
  final AppStrings strings;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final profile = viewState.hardwareProfile;
    final isOpponent = side != viewState.playerSide;
    final configuredDepth = isOpponent
        ? viewState.opponentDepth.opponentDepth
        : viewState.teacherDepth.teacherDepth;
    final analysis = isOpponent ? viewState.opponentAnalysis : viewState.hint;
    final engineDepth = 'D$configuredDepth';
    final engineEval = analysis?.evaluationLabel ?? '--';
    final engineTime = analysis == null ? '--' : '${analysis.elapsedMs}ms';
    final engineThreads = viewState.engineResources.auto && profile != null
        ? '${profile.recommendedThreads}'
        : '${viewState.engineResources.threads}';
    final engineHash = viewState.engineResources.auto && profile != null
        ? '${profile.recommendedHashMb} MB'
        : '${viewState.engineResources.hashMb} MB';
    final tooltip = [
      '${strings.depth}: $engineDepth',
      '${strings.evaluation}: $engineEval',
      '${strings.time}: $engineTime',
      '${strings.threads}: $engineThreads',
      '${strings.hash}: $engineHash',
    ].join('\n');

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.help,
        child: RepaintBoundary(
          child: dense
              ? clock
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [identity, const SizedBox(height: 6), clock],
                ),
        ),
      ),
    );
  }
}

class _SideIdentityCard extends StatelessWidget {
  const _SideIdentityCard({
    required this.name,
    required this.subtitle,
    required this.tone,
    required this.icon,
  });

  final String name;
  final String subtitle;
  final Color tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tone.withValues(alpha: 0.52)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: tone.withValues(alpha: 0.14),
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tone.withValues(alpha: 0.58)),
            ),
            child: Icon(icon, color: tone, size: 21),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardClock extends StatelessWidget {
  const _BoardClock({
    required this.label,
    required this.milliseconds,
    required this.active,
    required this.tone,
  });

  final String label;
  final int? milliseconds;
  final bool active;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final unlimited = milliseconds == null;
    final lowTime = milliseconds != null && milliseconds! <= 15000;
    final accent = lowTime ? const Color(0xFFFF6B5F) : tone;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.22)
            : Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.72)
              : Colors.white.withValues(alpha: 0.12),
          width: active ? 2 : 1,
        ),
        boxShadow: [
          if (active)
            BoxShadow(
              blurRadius: 20,
              color: accent.withValues(alpha: 0.22),
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_rounded,
                size: 18,
                color: active ? accent : Colors.white54,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              unlimited ? '--:--' : _formatClock(milliseconds!),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: lowTime ? accent : Colors.white,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatClock(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _DialogueRail extends StatelessWidget {
  const _DialogueRail({
    required this.opponentIcon,
    required this.opponentTone,
    required this.opponentName,
    required this.opponentMessage,
    required this.opponentMessageSource,
    required this.coachName,
    required this.coachMessage,
    required this.coachMessageSource,
    required this.aiThinking,
    required this.llmStatusMessage,
    required this.llmError,
    required this.textScale,
  });

  final IconData opponentIcon;
  final Color opponentTone;
  final String opponentName;
  final String opponentMessage;
  final DialogueMessageSource opponentMessageSource;
  final String coachName;
  final String coachMessage;
  final DialogueMessageSource coachMessageSource;
  final bool aiThinking;
  final String? llmStatusMessage;
  final String? llmError;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(
      Localizations.localeOf(context).languageCode == 'zh'
          ? AppLocale.zhHant
          : AppLocale.en,
    );
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 11,
                child: _DialogueTile(
                  icon: opponentIcon,
                  tone: opponentTone,
                  speaker: opponentName,
                  message: opponentMessage,
                  source: opponentMessageSource,
                  light: true,
                  busy: aiThinking,
                  textScale: textScale,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 11,
                child: _DialogueTile(
                  icon: Icons.auto_awesome_rounded,
                  tone: const Color(0xFFE6C55C),
                  speaker: coachName,
                  message: coachMessage,
                  source: coachMessageSource,
                  light: false,
                  busy: false,
                  textScale: textScale,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          child: (llmError?.isNotEmpty ?? false)
              ? _LlmStatusStrip(
                  status: llmStatusMessage,
                  error: llmError,
                  textScale: textScale,
                  strings: strings,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _DialogueTile extends StatefulWidget {
  const _DialogueTile({
    required this.icon,
    required this.tone,
    required this.speaker,
    required this.message,
    required this.source,
    required this.light,
    required this.busy,
    required this.textScale,
  });

  final IconData icon;
  final Color tone;
  final String speaker;
  final String message;
  final DialogueMessageSource source;
  final bool light;
  final bool busy;
  final double textScale;

  @override
  State<_DialogueTile> createState() => _DialogueTileState();
}

class _DialogueTileState extends State<_DialogueTile> {
  var _showMarkdown = false;

  @override
  void initState() {
    super.initState();
    _showMarkdown = widget.message.isEmpty;
  }

  @override
  void didUpdateWidget(covariant _DialogueTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _showMarkdown = widget.message.isEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.light
        ? const Color(0xFFF4F0E9)
        : const Color(0xFF26302C).withValues(alpha: 0.94);
    final bodyColor = widget.light ? const Color(0xFF24211C) : Colors.white;
    final bodyStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: bodyColor,
      fontWeight: FontWeight.w900,
      height: 1.26,
      fontSize:
          ((Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) + 2) *
          widget.textScale,
    );

    return Container(
      constraints: const BoxConstraints.expand(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.light ? const Color(0x22FFFFFF) : Colors.white10,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: Color(0x22000000),
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.tone.withValues(alpha: widget.light ? 0.14 : 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.tone.withValues(alpha: 0.48)),
            ),
            child: widget.busy
                ? const Padding(
                    padding: EdgeInsets.all(9),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(widget.icon, color: widget.tone, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _showMarkdown
                    ? _AutoScrollDialogueBody(
                        key: ValueKey('scroll-markdown-${widget.message}'),
                        child: _DialogueMarkdown(
                          key: ValueKey('markdown-${widget.message}'),
                          message: widget.message,
                          style: bodyStyle,
                          textColor: bodyColor,
                          light: widget.light,
                        ),
                      )
                    : _AutoScrollDialogueBody(
                        key: ValueKey('scroll-typing-${widget.message}'),
                        child: TypewriterText(
                          key: ValueKey('typing-${widget.message}'),
                          text: widget.message,
                          style: bodyStyle,
                          overflow: TextOverflow.visible,
                          onCompleted: () {
                            if (!mounted) {
                              return;
                            }
                            setState(() => _showMarkdown = true);
                          },
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoScrollDialogueBody extends StatefulWidget {
  const _AutoScrollDialogueBody({super.key, required this.child});

  final Widget child;

  @override
  State<_AutoScrollDialogueBody> createState() =>
      _AutoScrollDialogueBodyState();
}

class _AutoScrollDialogueBodyState extends State<_AutoScrollDialogueBody> {
  final ScrollController _controller = ScrollController();
  bool _scrollQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleScroll());
  }

  @override
  void didUpdateWidget(covariant _AutoScrollDialogueBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleScroll());
  }

  void _scheduleScroll() {
    if (!mounted || !_controller.hasClients || _scrollQueued) {
      return;
    }
    _scrollQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollQueued = false;
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final extent = _controller.position.maxScrollExtent;
      if (extent <= 0) {
        return;
      }
      final target = math
          .max(_controller.offset, extent)
          .clamp(0.0, extent)
          .toDouble();
      _controller.animateTo(
        target,
        duration: Duration(
          milliseconds: math.max(
            1800,
            ((target - _controller.offset).abs() * 22).round(),
          ),
        ),
        curve: Curves.linear,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0.0, 0.08, 0.92, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        child: Align(alignment: Alignment.topLeft, child: widget.child),
      ),
    );
  }
}

class _DialogueMarkdown extends StatelessWidget {
  const _DialogueMarkdown({
    super.key,
    required this.message,
    required this.style,
    required this.textColor,
    required this.light,
  });

  final String message;
  final TextStyle? style;
  final Color textColor;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final safeMessage = sanitizeDisplayText(message);
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    final sheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base,
      pPadding: EdgeInsets.zero,
      strong: base?.copyWith(fontWeight: FontWeight.w900),
      em: base?.copyWith(fontStyle: FontStyle.italic),
      listBullet: base?.copyWith(color: textColor, fontWeight: FontWeight.w900),
      blockquote: base?.copyWith(
        color: textColor.withValues(alpha: 0.92),
        height: 1.24,
      ),
      blockquoteDecoration: BoxDecoration(
        color: light ? const Color(0x14000000) : const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: light ? const Color(0x22000000) : const Color(0x22FFFFFF),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      code: base?.copyWith(
        fontFamily: 'monospace',
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      codeblockDecoration: BoxDecoration(
        color: light ? const Color(0x12000000) : const Color(0x14000000),
        borderRadius: BorderRadius.circular(10),
      ),
      codeblockPadding: const EdgeInsets.all(10),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: light ? const Color(0x22000000) : const Color(0x22FFFFFF),
          ),
        ),
      ),
    );

    return MarkdownBody(
      data: safeMessage,
      shrinkWrap: true,
      selectable: false,
      softLineBreak: true,
      styleSheet: sheet,
      listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
    );
  }
}

class _LlmStatusStrip extends StatelessWidget {
  const _LlmStatusStrip({
    required this.status,
    required this.error,
    required this.textScale,
    required this.strings,
  });

  final String? status;
  final String? error;
  final double textScale;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeStatus = status == null ? null : sanitizeDisplayText(status!);
    if (safeStatus == null || safeStatus.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        children: [
          Icon(Icons.hub_rounded, size: 18, color: const Color(0xFF8FD4C1)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              safeStatus,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
                fontSize:
                    (theme.textTheme.bodyMedium?.fontSize ?? 14) * textScale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
