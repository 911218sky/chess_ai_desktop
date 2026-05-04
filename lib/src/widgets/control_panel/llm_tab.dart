import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../i18n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../models/session_config.dart';
import '../../theme/app_theme.dart';
import 'primitives.dart';

class LlmTab extends StatefulWidget {
  const LlmTab({
    super.key,
    required this.state,
    required this.onLlmEnabledChanged,
    required this.onPersonaChanged,
    required this.onCoachPersonaChanged,
    required this.onLlmProviderChanged,
    required this.onLlmBaseUrlChanged,
    required this.onLlmModelChanged,
    required this.onLlmApiKeyChanged,
    required this.onLlmIdleBanterEnabledChanged,
    required this.onLlmIdleBanterMinSecondsChanged,
    required this.onLlmIdleBanterMaxSecondsChanged,
    required this.onResetLlmStatsPressed,
    required this.onTestLlmPressed,
    required this.onFetchLlmModelsPressed,
    required this.onResetLlmPressed,
  });

  final GameState state;
  final ValueChanged<bool> onLlmEnabledChanged;
  final ValueChanged<Persona> onPersonaChanged;
  final ValueChanged<CoachPersona> onCoachPersonaChanged;
  final ValueChanged<String> onLlmProviderChanged;
  final ValueChanged<String> onLlmBaseUrlChanged;
  final ValueChanged<String> onLlmModelChanged;
  final ValueChanged<String> onLlmApiKeyChanged;
  final ValueChanged<bool> onLlmIdleBanterEnabledChanged;
  final ValueChanged<int> onLlmIdleBanterMinSecondsChanged;
  final ValueChanged<int> onLlmIdleBanterMaxSecondsChanged;
  final VoidCallback onResetLlmStatsPressed;
  final Future<void> Function() onTestLlmPressed;
  final Future<void> Function() onFetchLlmModelsPressed;
  final Future<void> Function() onResetLlmPressed;

  @override
  State<LlmTab> createState() => _LlmTabState();
}

class _LlmTabState extends State<LlmTab> {
  late final TextEditingController _providerController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final llm = widget.state.config.llm;
    _providerController = TextEditingController(text: llm.provider);
    _baseUrlController = TextEditingController(text: llm.baseUrl);
    _modelController = TextEditingController(text: llm.model);
    _apiKeyController = TextEditingController(text: llm.apiKey);
  }

  @override
  void didUpdateWidget(LlmTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLlm = oldWidget.state.config.llm;
    final llm = widget.state.config.llm;
    if (oldLlm.provider != llm.provider) {
      _syncTextController(_providerController, llm.provider);
    }
    if (oldLlm.baseUrl != llm.baseUrl) {
      _syncTextController(_baseUrlController, llm.baseUrl);
    }
    if (oldLlm.model != llm.model) {
      _syncTextController(_modelController, llm.model);
    }
    if (oldLlm.apiKey != llm.apiKey) {
      _syncTextController(_apiKeyController, llm.apiKey);
    }
  }

  @override
  void dispose() {
    _providerController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _syncTextController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final strings = AppStrings.of(state.config.locale);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ControlSectionBand(
            title: strings.llmRoles,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.enableLlmVoices),
                  subtitle: Text(strings.llmVoicesDescription),
                  value: state.config.llm.enabled,
                  onChanged: widget.onLlmEnabledChanged,
                ),
                const SizedBox(height: 8),
                LabeledDropdown<Persona>(
                  label: strings.opponentAttitude,
                  value: state.config.persona,
                  items: Persona.values,
                  itemLabel: (item) => item.localizedLabel(strings),
                  onChanged: widget.onPersonaChanged,
                ),
                const SizedBox(height: 14),
                LabeledDropdown<CoachPersona>(
                  label: strings.teacherVoice,
                  value: state.config.coachPersona,
                  items: CoachPersona.values,
                  itemLabel: (item) => item.localizedLabel(strings),
                  onChanged: widget.onCoachPersonaChanged,
                ),
                const SizedBox(height: 14),
                LabeledTextField(
                  label: strings.provider,
                  controller: _providerController,
                  onChanged: widget.onLlmProviderChanged,
                ),
                const SizedBox(height: 14),
                LabeledTextField(
                  label: strings.baseUrl,
                  controller: _baseUrlController,
                  onChanged: widget.onLlmBaseUrlChanged,
                ),
                const SizedBox(height: 14),
                LabeledTextField(
                  label: strings.model,
                  controller: _modelController,
                  onChanged: widget.onLlmModelChanged,
                ),
                if (state.availableLlmModels.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  LabeledDropdown<String>(
                    label: strings.availableModels,
                    value:
                        state.availableLlmModels.contains(
                          state.config.llm.model,
                        )
                        ? state.config.llm.model
                        : state.availableLlmModels.first,
                    items: state.availableLlmModels,
                    itemLabel: (item) => item,
                    onChanged: widget.onLlmModelChanged,
                  ),
                ],
                const SizedBox(height: 14),
                LabeledTextField(
                  label: strings.apiKey,
                  controller: _apiKeyController,
                  obscureText: true,
                  onChanged: widget.onLlmApiKeyChanged,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AsyncActionButton(
                        icon: Icons.wifi_tethering_rounded,
                        label: strings.test,
                        busy: state.llmTesting,
                        onPressed: widget.onTestLlmPressed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AsyncActionButton(
                        icon: Icons.cloud_sync_rounded,
                        label: strings.fetchModels,
                        busy: state.llmFetchingModels,
                        onPressed: widget.onFetchLlmModelsPressed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _AsyncActionButton(
                    icon: Icons.restore_rounded,
                    label: strings.resetLlm,
                    busy: false,
                    onPressed: widget.onResetLlmPressed,
                  ),
                ),
                if (state.llmStatusMessage != null) ...[
                  const SizedBox(height: 12),
                  _StatusNotice(message: state.llmStatusMessage!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          ControlSectionBand(
            title: strings.llmUsageStats,
            child: _LlmUsageCard(
              stats: state.llmStats,
              strings: strings,
              onReset: widget.onResetLlmStatsPressed,
            ),
          ),
          const SizedBox(height: 14),
          ControlSectionBand(
            title: strings.llmIdleBanter,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.enableIdleBanter),
                  subtitle: Text(strings.idleBanterDescription),
                  value: state.config.llm.idleBanterEnabled,
                  onChanged: widget.onLlmIdleBanterEnabledChanged,
                ),
                const SizedBox(height: 8),
                SegmentedPicker<int>(
                  label: strings.minSeconds,
                  value: state.config.llm.idleBanterMinSeconds,
                  options: const [10, 18, 30, 45, 60],
                  itemLabel: (item) => '${item}s',
                  onChanged: widget.onLlmIdleBanterMinSecondsChanged,
                ),
                const SizedBox(height: 14),
                SegmentedPicker<int>(
                  label: strings.maxSeconds,
                  value: state.config.llm.idleBanterMaxSeconds,
                  options: const [20, 45, 60, 90, 120],
                  itemLabel: (item) => '${item}s',
                  onChanged: widget.onLlmIdleBanterMaxSecondsChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ControlSectionBand(
            title: strings.fallback,
            child: Text(
              strings.fallbackDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LlmUsageCard extends StatelessWidget {
  const _LlmUsageCard({
    required this.stats,
    required this.strings,
    required this.onReset,
  });

  final LlmUsageStats stats;
  final AppStrings strings;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final promptShare = stats.totalTokens == 0
        ? 0.0
        : stats.promptTokens / stats.totalTokens;
    final outputShare = stats.totalTokens == 0
        ? 0.0
        : stats.completionTokens / stats.totalTokens;
    final latency = stats.lastLatencyMs == null
        ? '-'
        : '${stats.lastLatencyMs} ms';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _UsageHeroMetric(
                icon: Icons.forum_rounded,
                label: strings.llmRequests,
                value: stats.requestCount,
                accent: AppColors.primary,
                details: [
                  '${strings.llmSuccessfulRequests} ${stats.successCount}',
                  '${strings.llmFailedRequests} ${stats.failureCount}',
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: SquareIconAction(
                icon: Icons.restart_alt_rounded,
                active: false,
                tooltip: strings.resetLlmUsageStats,
                onTap: onReset,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _TokenMeter(
          total: stats.totalTokens,
          prompt: stats.promptTokens,
          output: stats.completionTokens,
          promptShare: promptShare,
          outputShare: outputShare,
          strings: strings,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _UsageMiniMetric(
                label: strings.llmPromptTokens,
                value: stats.promptTokens,
                color: const Color(0xFF8CC6FF),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _UsageMiniMetric(
                label: strings.llmOutputTokens,
                value: stats.completionTokens,
                color: const Color(0xFFFFC66D),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _UsageMiniMetric(
                label: strings.llmLastResponse,
                value: latency,
                color: const Color(0xFFBBA8FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UsageHeroMetric extends StatelessWidget {
  const _UsageHeroMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.details,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color accent;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.36)),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                _AnimatedUsageNumber(
                  value: value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final detail in details)
                      Text(
                        detail,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenMeter extends StatelessWidget {
  const _TokenMeter({
    required this.total,
    required this.prompt,
    required this.output,
    required this.promptShare,
    required this.outputShare,
    required this.strings,
  });

  final int total;
  final int prompt;
  final int output;
  final double promptShare;
  final double outputShare;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promptFlex = total == 0
        ? 1
        : math.max(1, (promptShare * 100).round());
    final outputFlex = total == 0
        ? 1
        : math.max(1, (outputShare * 100).round());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                strings.llmTokens,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedUsageNumber(
                    value: total,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    strings.llmTotalTokens,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 9,
              child: Row(
                children: [
                  Expanded(
                    flex: promptFlex,
                    child: Container(color: const Color(0xFF8CC6FF)),
                  ),
                  Expanded(
                    flex: outputFlex,
                    child: Container(color: const Color(0xFFFFC66D)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageMiniMetric extends StatelessWidget {
  const _UsageMiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final Object value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          if (value is int)
            _AnimatedUsageNumber(
              value: value as int,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            )
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$value',
                maxLines: 1,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedUsageNumber extends StatelessWidget {
  const _AnimatedUsageNumber({required this.value, required this.style});

  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final progress = value == 0
            ? 1.0
            : (animatedValue / value).clamp(0.0, 1.0);
        final slide = (1.0 - progress) * 8;

        return Transform.translate(
          offset: Offset(0, slide),
          child: Opacity(
            opacity: 0.55 + (0.45 * progress),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                animatedValue.round().toString(),
                maxLines: 1,
                style: style,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AsyncActionButton extends StatelessWidget {
  const _AsyncActionButton({
    required this.icon,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool busy;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final failed = message.toLowerCase().contains('failed');
    final color = failed ? const Color(0xFFFF845E) : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
