import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/app_riverpod_state.dart';
import '../../core/theme/ui_tokens.dart';
import 'insights_provider.dart';
import 'insight_models.dart';

class InsightsScreen extends ConsumerWidget {
  static const routeName = '/insights';
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final appState = ref.watch(appStateProvider);
    final currencyCode = appState.currencyCode;

    final items = ref.watch(weeklyInsightsProvider);

    // Grab a few key items for the hero
    final summary = items.firstWhere(
      (x) => x.type == InsightType.summary,
      orElse: () => const InsightItem(
        type: InsightType.summary,
        title: "This week",
        message: "No spending data yet.",
      ),
    );

    final trend = items.firstWhere(
      (x) => x.type == InsightType.trend,
      orElse: () => const InsightItem(
        type: InsightType.trend,
        title: "Compared to last week",
        message: "Not enough data to compare yet.",
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Insights"),
      ),
      body: items.isEmpty
          ? const Center(child: Text("No insights yet"))
          : ListView(
              padding: const EdgeInsets.fromLTRB(Ui.s16, Ui.s12, Ui.s16, Ui.s24),
              children: [
                _InsightsHero(
                  title: summary.title,
                  subtitle: _decorateMessage(summary.message, currencyCode),
                  trendText: _decorateMessage(trend.message, currencyCode),
                  trendValue: trend.value,
                ),
                const SizedBox(height: Ui.s14),

                Text(
                  "Your week at a glance",
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: Ui.s10),

                ...items.map((it) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Ui.s12),
                    child: _InsightCard(
                      item: it,
                      message: _decorateMessage(it.message, currencyCode),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  String _decorateMessage(String msg, String currencyCode) {
    // Replace any hard-coded PKR from engine (if any)
    return msg.replaceAll("PKR", currencyCode);
  }
}

/* ------------------------------ Hero ------------------------------ */

class _InsightsHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trendText;
  final double? trendValue;

  const _InsightsHero({
    required this.title,
    required this.subtitle,
    required this.trendText,
    required this.trendValue,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final isUp = (trendValue ?? 0) > 0;
    final hasPct = trendValue != null;

    Color chipBg;
    Color chipFg;

    if (!hasPct) {
      chipBg = cs.surfaceContainerHighest.withValues(alpha: 0.55);
      chipFg = cs.onSurfaceVariant;
    } else if (isUp) {
      chipBg = cs.errorContainer;
      chipFg = cs.onErrorContainer;
    } else {
      chipBg = cs.tertiaryContainer;
      chipFg = cs.onTertiaryContainer;
    }

    return Container(
      padding: const EdgeInsets.all(Ui.s16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(Ui.r28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Coach",
            style: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            title,
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            subtitle,
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Trend chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
            ),
            child: Text(
              trendText,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: chipFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Insight Card ------------------------------ */

class _InsightCard extends StatelessWidget {
  final InsightItem item;
  final String message;

  const _InsightCard({required this.item, required this.message});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final accent = _accentColor(cs, item.type);
    final tag = _tag(item.type);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(Ui.r24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.30)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent strip
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Ui.r24),
                  bottomLeft: Radius.circular(Ui.r24),
                ),
              ),
            ),
        
            Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Ui.s14, Ui.s14, Ui.s14, Ui.s14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ add this too
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      tag,
                      style: t.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: t.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
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

  String _tag(InsightType t) {
    switch (t) {
      case InsightType.summary:
        return "Summary";
      case InsightType.trend:
        return "Trend";
      case InsightType.category:
        return "Category";
      case InsightType.daySpike:
        return "Pattern";
      case InsightType.suggestion:
        return "Action";
    }
  }

  Color _accentColor(ColorScheme cs, InsightType t) {
    switch (t) {
      case InsightType.summary:
        return cs.primary;
      case InsightType.trend:
        return cs.tertiary;
      case InsightType.category:
        return cs.secondary;
      case InsightType.daySpike:
        return cs.primaryContainer;
      case InsightType.suggestion:
        return cs.errorContainer; // gives “take action” vibe
    }
  }
}
