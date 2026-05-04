import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chess_ai_desktop/src/i18n/app_localizations.dart';
import 'package:chess_ai_desktop/src/models/bot_roster.dart';
import 'package:chess_ai_desktop/src/models/engine_models.dart';
import 'package:chess_ai_desktop/src/models/game_state.dart';
import 'package:chess_ai_desktop/src/models/session_config.dart';
import 'package:chess_ai_desktop/src/widgets/control_panel.dart';

void main() {
  test('control panel view state ignores board-only updates', () {
    final state = _stateWithLlm(const LlmSettings());
    final viewState = ControlPanelViewState.fromGameState(state);
    final boardOnlyUpdate = ControlPanelViewState.fromGameState(
      state.copyWith(
        selectedSquare: Square.e2,
        legalTargets: {Square.e4},
        whiteClockMs: 59000,
        opponentAnalysis: const EngineAnalysis(
          bestMoveUci: 'e7e5',
          depth: 10,
          lines: [],
          elapsedMs: 30,
        ),
      ),
    );

    expect(boardOnlyUpdate, viewState);
  });

  testWidgets('syncs LLM text fields when settings change externally', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final customState = _stateWithLlm(
      const LlmSettings(
        enabled: true,
        provider: 'Custom Gateway',
        baseUrl: 'https://llm.example.test/v1',
        model: 'custom-model',
        apiKey: 'secret-token',
      ),
    );

    await _pumpControlPanel(tester, customState);
    await tester.tap(find.text('LLM'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Gateway'), findsOneWidget);
    expect(find.text('https://llm.example.test/v1'), findsOneWidget);
    expect(find.text('custom-model'), findsOneWidget);

    await _pumpControlPanel(tester, _stateWithLlm(const LlmSettings()));
    await tester.pumpAndSettle();

    expect(find.text('Custom Gateway'), findsNothing);
    expect(find.text('https://llm.example.test/v1'), findsNothing);
    expect(find.text('custom-model'), findsNothing);
    expect(find.text('OpenAI Compatible'), findsOneWidget);
    expect(find.text('https://api.openai.com/v1'), findsOneWidget);
    expect(find.text('gpt-5.5'), findsOneWidget);
    expect(_llmTextField(tester, 3).controller?.text, isEmpty);
  });

  testWidgets('preserves active LLM edits during unrelated parent rebuild', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final state = _stateWithLlm(const LlmSettings());

    await _pumpControlPanel(tester, state);
    await tester.tap(find.text('LLM'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Editing Gateway');
    await tester.pump();

    await _pumpControlPanel(tester, state.copyWith(aiThinking: true));
    await tester.pump();

    expect(_llmTextField(tester, 0).controller?.text, 'Editing Gateway');
  });

  testWidgets('syncs hidden LLM API key when settings change externally', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpControlPanel(
      tester,
      _stateWithLlm(const LlmSettings(apiKey: 'first-secret')),
    );
    await tester.tap(find.text('LLM'));
    await tester.pumpAndSettle();

    expect(_llmTextField(tester, 3).controller?.text, 'first-secret');

    await _pumpControlPanel(
      tester,
      _stateWithLlm(const LlmSettings(apiKey: 'second-secret')),
    );
    await tester.pumpAndSettle();

    expect(_llmTextField(tester, 3).controller?.text, 'second-secret');
  });

  testWidgets('shows LLM usage stats and idle banter controls', (tester) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var resetStatsPressed = false;
    var idleEnabled = false;
    var minSeconds = 0;
    var maxSeconds = 0;
    final state =
        _stateWithLlm(
          const LlmSettings(
            enabled: true,
            idleBanterEnabled: true,
            idleBanterMinSeconds: 10,
            idleBanterMaxSeconds: 45,
          ),
        ).copyWith(
          llmStats: const LlmUsageStats(
            requestCount: 3,
            successCount: 2,
            failureCount: 1,
            promptTokens: 30,
            completionTokens: 12,
            totalTokens: 42,
            lastLatencyMs: 321,
          ),
        );

    await _pumpControlPanel(
      tester,
      state,
      onResetLlmStatsPressed: () {
        resetStatsPressed = true;
      },
      onLlmIdleBanterEnabledChanged: (value) {
        idleEnabled = value;
      },
      onLlmIdleBanterMinSecondsChanged: (value) {
        minSeconds = value;
      },
      onLlmIdleBanterMaxSecondsChanged: (value) {
        maxSeconds = value;
      },
    );
    await tester.tap(find.text('LLM'));
    await tester.pumpAndSettle();

    expect(find.text('LLM Usage'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Success 2'), findsOneWidget);
    expect(find.text('Failed 1'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Prompt'), findsOneWidget);
    expect(find.text('Output'), findsOneWidget);
    expect(find.text('321 ms'), findsOneWidget);
    expect(find.text('Idle Banter'), findsOneWidget);

    final resetButton = find.byTooltip('Reset LLM usage counters');
    await tester.ensureVisible(resetButton);
    await tester.pumpAndSettle();
    await tester.tap(resetButton);
    await tester.pump();
    expect(resetStatsPressed, isTrue);

    final idleSwitch = find.widgetWithText(SwitchListTile, 'Random idle lines');
    await tester.ensureVisible(idleSwitch);
    await tester.pumpAndSettle();
    await tester.tap(idleSwitch);
    await tester.pump();
    expect(idleEnabled, isFalse);

    final minChip = find.widgetWithText(ChoiceChip, '10s').first;
    await tester.ensureVisible(minChip);
    await tester.pumpAndSettle();
    await tester.tap(minChip);
    await tester.pump();
    expect(minSeconds, 10);

    final maxChip = find.widgetWithText(ChoiceChip, '90s').first;
    await tester.ensureVisible(maxChip);
    await tester.pumpAndSettle();
    await tester.tap(maxChip);
    await tester.pump();
    expect(maxSeconds, 90);
  });

  testWidgets('selecting a collapsed bot category starts with that profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    GameSessionConfig? requestedConfig;
    await _pumpControlPanel(
      tester,
      _stateWithLlm(const LlmSettings()),
      onNewGamePressed: ({config}) async {
        requestedConfig = config;
      },
    );

    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();

    final expectedProfile = botRoster.firstWhere(
      (profile) => profile.category == 'Beginner',
    );
    expect(requestedConfig, isNotNull);
    expect(requestedConfig!.difficulty, expectedProfile.difficulty);
    expect(requestedConfig!.persona, expectedProfile.persona);
    expect(requestedConfig!.tauntLevel, expectedProfile.tauntLevel);
  });

  testWidgets('selecting player side in match tab invokes callback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Side? selectedSide;
    await _pumpControlPanel(
      tester,
      _stateWithLlm(const LlmSettings()),
      onPlayerSideChanged: (side) {
        selectedSide = side;
      },
    );

    await tester.tap(find.text('Match'));
    await tester.pumpAndSettle();
    final blackSideChip = find.widgetWithText(ChoiceChip, 'black');
    await tester.ensureVisible(blackSideChip);
    await tester.tap(blackSideChip);
    await tester.pumpAndSettle();

    expect(selectedSide, Side.black);
  });

  testWidgets('selecting taunt level in coach tab invokes callback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    TauntLevel? selectedTauntLevel;
    await _pumpControlPanel(
      tester,
      _stateWithLlm(const LlmSettings()),
      onTauntLevelChanged: (level) {
        selectedTauntLevel = level;
      },
    );

    await tester.tap(find.text('Coach'));
    await tester.pumpAndSettle();
    final fullTauntChip = find.widgetWithText(ChoiceChip, 'Full');
    await tester.ensureVisible(fullTauntChip);
    await tester.tap(fullTauntChip);
    await tester.pumpAndSettle();

    expect(selectedTauntLevel, TauntLevel.full);
  });

  testWidgets('coach tab does not duplicate live review content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final review = _review(
      moveUci: 'e2e4',
      quality: MoveQuality.best,
      centipawnLoss: 0,
      elapsedMs: 1200,
    );
    final state = _stateWithLlm(
      const LlmSettings(),
    ).copyWith(latestReview: review, reviewHistory: [review]);

    await _pumpControlPanel(tester, state);
    await tester.tap(find.text('Coach'));
    await tester.pumpAndSettle();

    expect(find.text('Coach Feed'), findsOneWidget);
    expect(find.text('Personality'), findsOneWidget);
    expect(find.text('Reviewed'), findsNothing);
    expect(find.text('Played'), findsNothing);
  });

  testWidgets('keeps review tab inaccessible until a review exists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final state = _stateWithLlm(const LlmSettings());
    final strings = AppStrings.of(state.config.locale);

    await _pumpControlPanel(tester, state);
    await tester.tap(find.text(strings.liveReview));
    await tester.pumpAndSettle();

    expect(find.text(strings.waitingForMoveReview), findsNothing);
    expect(find.text('Beginner'), findsOneWidget);
  });

  testWidgets('shows whole-game review stats in live review', (tester) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final reviews = [
      _review(
        moveUci: 'e2e4',
        quality: MoveQuality.best,
        centipawnLoss: 0,
        elapsedMs: 1200,
      ),
      _review(
        moveUci: 'g1f3',
        quality: MoveQuality.mistake,
        centipawnLoss: 80,
        elapsedMs: 3400,
      ),
      _review(
        moveUci: 'f1c4',
        quality: MoveQuality.blunder,
        centipawnLoss: 260,
        elapsedMs: 5600,
      ),
    ];
    final state = _stateWithLlm(
      const LlmSettings(),
    ).copyWith(latestReview: reviews.last, reviewHistory: reviews);

    await _pumpControlPanel(tester, state);
    await tester.tap(find.text('Live Review'));
    await tester.pumpAndSettle();

    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('Good moves'), findsOneWidget);
    expect(find.text('Problem moves'), findsOneWidget);
    expect(find.text('Mistakes'), findsOneWidget);
    expect(find.text('Missed chances'), findsOneWidget);
    expect(find.text('Critical mistakes'), findsOneWidget);
    expect(find.text('Avg CP'), findsOneWidget);
    expect(find.text('Avg pace'), findsOneWidget);
    expect(find.text('Last pace'), findsOneWidget);
    expect(find.text('Blunder'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(3));
    expect(find.text('113'), findsOneWidget);
    expect(find.text('3.4s'), findsOneWidget);
    expect(find.text('5.6s'), findsOneWidget);
  });

  testWidgets('shows live review labels in Traditional Chinese', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final review = _review(
      moveUci: 'f1c4',
      quality: MoveQuality.blunder,
      centipawnLoss: 260,
      elapsedMs: 5600,
    );
    final state = GameState.initial(
      config: GameSessionConfig.defaults().copyWith(locale: AppLocale.zhHant),
    ).copyWith(latestReview: review, reviewHistory: [review]);

    await _pumpControlPanel(tester, state);
    await tester.tap(find.text('即時覆盤'));
    await tester.pumpAndSettle();

    expect(find.text('大失誤'), findsOneWidget);
    expect(find.text('已覆盤'), findsOneWidget);
    expect(find.text('好棋'), findsOneWidget);
    expect(find.text('問題手'), findsOneWidget);
    expect(find.text('漏失機會'), findsOneWidget);
    expect(find.text('嚴重失誤'), findsOneWidget);
    expect(find.text('平均損失'), findsOneWidget);
  });

  testWidgets('keeps active tab state during unrelated parent rebuild', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final state = _stateWithLlm(const LlmSettings());

    await _pumpControlPanel(tester, state);
    await tester.tap(find.text('Coach'));
    await tester.pumpAndSettle();

    await _pumpControlPanel(tester, state.copyWith(aiThinking: true));
    await tester.pumpAndSettle();

    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('Play Bots'), findsOneWidget);
  });
}

TextFormField _llmTextField(WidgetTester tester, int index) {
  return tester.widget<TextFormField>(find.byType(TextFormField).at(index));
}

GameState _stateWithLlm(LlmSettings llm) {
  return GameState.initial(
    config: GameSessionConfig.defaults().copyWith(llm: llm),
  );
}

MoveReview _review({
  required String moveUci,
  required MoveQuality quality,
  required int centipawnLoss,
  required int elapsedMs,
}) {
  return MoveReview(
    moveUci: moveUci,
    bestMoveUci: 'e2e4',
    quality: quality,
    expectedDrop: 0,
    centipawnLoss: centipawnLoss,
    whiteWinPercent: 45,
    drawPercent: 20,
    blackWinPercent: 35,
    beforeEvaluation: '+0.20',
    afterEvaluation: '-0.10',
    elapsedMs: elapsedMs,
  );
}

Future<void> _pumpControlPanel(
  WidgetTester tester,
  GameState state, {
  Future<void> Function({GameSessionConfig? config})? onNewGamePressed,
  ValueChanged<Side>? onPlayerSideChanged,
  ValueChanged<TauntLevel>? onTauntLevelChanged,
  ValueChanged<bool>? onLlmIdleBanterEnabledChanged,
  ValueChanged<int>? onLlmIdleBanterMinSecondsChanged,
  ValueChanged<int>? onLlmIdleBanterMaxSecondsChanged,
  VoidCallback? onResetLlmStatsPressed,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 520,
          height: 900,
          child: ControlPanel(
            state: state,
            onDifficultyChanged: (_) {},
            onOpponentDepthChanged: (_) {},
            onTeacherDepthChanged: (_) {},
            onEngineResourcesChanged: (_) {},
            onTimeControlChanged: (_) {},
            onPlayerSideChanged: onPlayerSideChanged ?? (_) {},
            onHintModeChanged: (_) {},
            onCandidateLineCountChanged: (_) {},
            onAppTextScalePercentChanged: (_) {},
            onOpenAiPanelPressed: () {},
            onBoardThemeChanged: (_) {},
            onLocaleChanged: (_) {},
            onPersonaChanged: (_) {},
            onCoachPersonaChanged: (_) {},
            onTauntLevelChanged: onTauntLevelChanged ?? (_) {},
            onNewGamePressed: onNewGamePressed ?? ({config}) async {},
            onRematchPressed: () async {},
            onLlmEnabledChanged: (_) {},
            onLlmProviderChanged: (_) {},
            onLlmBaseUrlChanged: (_) {},
            onLlmModelChanged: (_) {},
            onLlmApiKeyChanged: (_) {},
            onLlmIdleBanterEnabledChanged:
                onLlmIdleBanterEnabledChanged ?? (_) {},
            onLlmIdleBanterMinSecondsChanged:
                onLlmIdleBanterMinSecondsChanged ?? (_) {},
            onLlmIdleBanterMaxSecondsChanged:
                onLlmIdleBanterMaxSecondsChanged ?? (_) {},
            onResetLlmStatsPressed: onResetLlmStatsPressed ?? () {},
            onTestLlmPressed: () async {},
            onFetchLlmModelsPressed: () async {},
            onResetLlmPressed: () async {},
            onResetPreferencesPressed: () async {},
          ),
        ),
      ),
    ),
  );
}
