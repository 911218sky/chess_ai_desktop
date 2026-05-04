import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../i18n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../models/session_config.dart';
import '../../theme/board_theme.dart';
import 'primitives.dart';

class MatchTab extends StatelessWidget {
  const MatchTab({
    super.key,
    required this.state,
    required this.onDifficultyChanged,
    required this.onOpponentDepthChanged,
    required this.onTeacherDepthChanged,
    required this.onEngineResourcesChanged,
    required this.onTimeControlChanged,
    required this.onPlayerSideChanged,
    required this.onHintModeChanged,
    required this.onCandidateLineCountChanged,
    required this.onAppTextScalePercentChanged,
    required this.onOpenAiPanelPressed,
    required this.onBoardThemeChanged,
    required this.onLocaleChanged,
    required this.onRematchPressed,
    required this.onResetPreferencesPressed,
  });

  final GameState state;
  final ValueChanged<DifficultyLevel> onDifficultyChanged;
  final ValueChanged<SearchDepthLevel> onOpponentDepthChanged;
  final ValueChanged<SearchDepthLevel> onTeacherDepthChanged;
  final ValueChanged<EngineResourceSettings> onEngineResourcesChanged;
  final ValueChanged<TimeControl> onTimeControlChanged;
  final ValueChanged<Side> onPlayerSideChanged;
  final ValueChanged<HintMode> onHintModeChanged;
  final ValueChanged<int> onCandidateLineCountChanged;
  final ValueChanged<int> onAppTextScalePercentChanged;
  final VoidCallback onOpenAiPanelPressed;
  final ValueChanged<BoardThemeId> onBoardThemeChanged;
  final ValueChanged<AppLocale> onLocaleChanged;
  final Future<void> Function() onRematchPressed;
  final Future<void> Function() onResetPreferencesPressed;

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    final strings = AppStrings.of(state.config.locale);
    final matchSetup = CollapsibleControlSectionBand(
      title: strings.matchSetup,
      initiallyExpanded: true,
      child: Column(
        children: [
          _MatchSummaryCard(state: state),
          const SizedBox(height: 14),
          LabeledDropdown<DifficultyLevel>(
            label: strings.difficulty,
            value: state.config.difficulty,
            items: DifficultyLevel.values,
            itemLabel: (item) => item.localizedLabel(strings),
            onChanged: onDifficultyChanged,
          ),
          const SizedBox(height: 14),
          LabeledDropdown<SearchDepthLevel>(
            label: strings.opponentStrength,
            value: state.config.opponentDepth,
            items: SearchDepthLevel.values,
            itemLabel: (item) => item.localizedLabel(strings),
            onChanged: onOpponentDepthChanged,
          ),
          const SizedBox(height: 14),
          LabeledDropdown<SearchDepthLevel>(
            label: strings.teacherStrength,
            value: state.config.teacherDepth,
            items: SearchDepthLevel.values,
            itemLabel: (item) => item.localizedLabel(strings),
            onChanged: onTeacherDepthChanged,
          ),
          const SizedBox(height: 14),
          _EngineResourceControls(
            state: state,
            onChanged: onEngineResourcesChanged,
          ),
          const SizedBox(height: 14),
          LabeledDropdown<TimeControl>(
            label: strings.timeControl,
            value: state.config.timeControl,
            items: TimeControl.values,
            itemLabel: (item) => item.localizedLabel(strings),
            onChanged: onTimeControlChanged,
          ),
          const SizedBox(height: 14),
          SegmentedPicker<Side>(
            label: strings.yourSide,
            value: state.config.playerSide,
            options: Side.values,
            itemLabel: (item) => strings.sideName(item.name),
            onChanged: onPlayerSideChanged,
          ),
          const SizedBox(height: 14),
          SegmentedPicker<HintMode>(
            label: strings.hints,
            value: state.config.hintMode,
            options: HintMode.values,
            itemLabel: (item) => item.localizedLabel(strings),
            onChanged: onHintModeChanged,
          ),
          if (state.config.hintMode == HintMode.candidateLines) ...[
            const SizedBox(height: 14),
            SegmentedPicker<int>(
              label: strings.candidateLineCount,
              value: state.config.candidateLineCount,
              options: const [2, 3, 4, 5],
              itemLabel: strings.candidateLineCountValue,
              onChanged: onCandidateLineCountChanged,
            ),
          ],
        ],
      ),
    );
    final displaySettings = CollapsibleControlSectionBand(
      title: strings.aiPanelSize,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedPicker<int>(
            label: strings.appTextSize,
            value: state.config.appTextScalePercent,
            options: const [85, 90, 100, 110, 120],
            itemLabel: strings.appTextSizeValue,
            onChanged: onAppTextScalePercentChanged,
          ),
          const SizedBox(height: 14),
          _ThemePicker(
            label: strings.boardTheme,
            value: state.config.boardTheme,
            onChanged: onBoardThemeChanged,
            strings: strings,
          ),
          const SizedBox(height: 14),
          LabeledDropdown<AppLocale>(
            label: strings.language,
            value: state.config.locale,
            items: AppLocale.values,
            itemLabel: (item) => item.localizedLabel(strings),
            onChanged: onLocaleChanged,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenAiPanelPressed,
              icon: const Icon(Icons.open_in_full_rounded),
              label: Text(strings.aiPanelExpanded),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          matchSetup,
          const SizedBox(height: 14),
          displaySettings,
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.aiThinking
                        ? null
                        : onResetPreferencesPressed,
                    icon: const Icon(Icons.restore_rounded),
                    label: Text(strings.resetPreferences),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.aiThinking ? null : onRematchPressed,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(strings.rematch),
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

class _MatchSummaryCard extends StatelessWidget {
  const _MatchSummaryCard({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final resources = state.config.engineResources;
    final strings = AppStrings.of(state.config.locale);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CompactMetric(
              label: strings.think,
              value: 'D${state.config.opponentDepth.opponentDepth}',
            ),
          ),
          Expanded(
            child: _CompactMetric(
              label: strings.threads,
              value: '${resources.threads}',
            ),
          ),
          Expanded(
            child: _CompactMetric(
              label: strings.hash,
              value: '${resources.hashMb} MB',
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineResourceControls extends StatelessWidget {
  const _EngineResourceControls({required this.state, required this.onChanged});

  final GameState state;
  final ValueChanged<EngineResourceSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(state.config.locale);
    final resources = state.config.engineResources;
    final profile = state.hardwareProfile;
    final detected = profile == null
        ? '--'
        : '${profile.cpuThreads} CPU / ${profile.memoryMb == null ? '--' : '${(profile.memoryMb! / 1024).toStringAsFixed(1)} GB'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.engineResources),
          subtitle: Text('${strings.detectedHardware}: $detected'),
          value: resources.auto,
          onChanged: (enabled) => onChanged(resources.copyWith(auto: enabled)),
        ),
        if (!resources.auto) ...[
          const SizedBox(height: 8),
          _NumberStepper(
            label: strings.threads,
            value: resources.threads,
            min: 1,
            max: 32,
            suffix: '',
            onChanged: (value) => onChanged(resources.copyWith(threads: value)),
          ),
          const SizedBox(height: 10),
          _NumberStepper(
            label: strings.hash,
            value: resources.hashMb,
            min: 16,
            max: 4096,
            step: 16,
            suffix: ' MB',
            onChanged: (value) => onChanged(resources.copyWith(hashMb: value)),
          ),
        ],
      ],
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.suffix = '',
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    void update(int delta) {
      onChanged((value + delta).clamp(min, max));
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
        ),
        SquareIconAction(
          icon: Icons.remove_rounded,
          active: false,
          tooltip: '-',
          onTap: value <= min ? null : () => update(-step),
        ),
        SizedBox(
          width: 92,
          child: Text(
            '$value$suffix',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        SquareIconAction(
          icon: Icons.add_rounded,
          active: false,
          tooltip: '+',
          onTap: value >= max ? null : () => update(step),
        ),
      ],
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.strings,
  });

  final String label;
  final BoardThemeId value;
  final ValueChanged<BoardThemeId> onChanged;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final themeId in BoardThemeId.values)
              _ThemeSwatchCard(
                themeId: themeId,
                selected: themeId == value,
                label: themeId.localizedLabel(strings),
                onTap: () => onChanged(themeId),
              ),
          ],
        ),
      ],
    );
  }
}

class _ThemeSwatchCard extends StatelessWidget {
  const _ThemeSwatchCard({
    required this.themeId,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final BoardThemeId themeId;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = boardThemeStyle(themeId);
    final accent = style.backdropAccent;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 150,
        height: 112,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
          color: style.panelTint.withValues(alpha: selected ? 0.82 : 0.46),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.95) : Colors.white12,
            width: selected ? 2.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: selected ? 22 : 14,
              color: (selected ? accent : Colors.black).withValues(
                alpha: selected ? 0.22 : 0.14,
              ),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            style.lightSquare.withValues(alpha: 0.98),
                            style.darkSquare.withValues(alpha: 0.98),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _SwatchBlock(
                          color: style.lightSquare.withValues(alpha: 0.84),
                        ),
                        _SwatchBlock(
                          color: style.darkSquare.withValues(alpha: 0.88),
                        ),
                        _SwatchBlock(color: accent.withValues(alpha: 0.86)),
                      ],
                    ),
                    if (selected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.26),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.96),
                height: 1.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchBlock extends StatelessWidget {
  const _SwatchBlock({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
    );
  }
}
