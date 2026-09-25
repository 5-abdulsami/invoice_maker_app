import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/palette.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/enums/currency.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';
import 'package:invoicemaker/core/utils/money.dart';
import 'package:invoicemaker/presentation/common/widgets/app_card.dart';
import 'package:invoicemaker/state/document_controller.dart';

/// Outstanding, overdue and collected money, one currency at a time.
///
/// Amounts in different currencies are never summed; when invoices use more
/// than one, a switcher above the figures picks which to show.
class SummarySection extends StatefulWidget {
  const SummarySection({
    super.key,
    required this.summaries,
    required this.moneyFor,
  }) : assert(summaries.length > 0, 'The default currency is always present');

  /// One summary per currency, the default currency first.
  final List<DocumentSummary> summaries;

  final MoneyFormat Function(Currency currency) moneyFor;

  @override
  State<SummarySection> createState() => _SummarySectionState();
}

class _SummarySectionState extends State<SummarySection> {
  Currency? _selected;

  @override
  Widget build(BuildContext context) {
    final summaries = widget.summaries;
    // Falls back to the default currency if the chosen one has gone, e.g.
    // after its last invoice was deleted.
    final summary = summaries.firstWhere(
      (summary) => summary.currency == _selected,
      orElse: () => summaries.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summaries.length > 1) ...[
          _CurrencySwitcher(
            currencies: [for (final summary in summaries) summary.currency],
            selected: summary.currency,
            onSelected: (currency) => setState(() => _selected = currency),
          ),
          Gap.h12,
        ],
        _SummaryTiles(
          summary: summary,
          money: widget.moneyFor(summary.currency),
        ),
      ],
    );
  }
}

class _CurrencySwitcher extends StatelessWidget {
  const _CurrencySwitcher({
    required this.currencies,
    required this.selected,
    required this.onSelected,
  });

  final List<Currency> currencies;
  final Currency selected;
  final ValueChanged<Currency> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final currency in currencies) ...[
            if (currency != currencies.first) Gap.w8,
            ChoiceChip(
              label: Text(currency.code),
              tooltip: currency.displayName,
              selected: currency == selected,
              onSelected: (_) => onSelected(currency),
            ),
          ],
        ],
      ),
    );
  }
}

/// The three figures, sized together.
///
/// Money is never truncated: every amount is always shown in full.
///
/// All three amounts share one type size, shrunk just enough for the longest
/// to fit, so a large balance never makes its neighbours look mismatched.
/// When that would make them too small to read, the tiles stack and each
/// amount gets the full width instead.
class _SummaryTiles extends StatelessWidget {
  const _SummaryTiles({required this.summary, required this.money});

  final DocumentSummary summary;
  final MoneyFormat money;

  /// Below this shrink factor side-by-side figures get hard to read.
  static const double _minSideBySideScale = 0.72;

  static const double _tilePadding = Insets.md;

  /// Headroom on the measured width. Glyph advances do not shrink exactly in
  /// proportion to the font size, so the shared size aims slightly small.
  static const double _fitMargin = 0.98;

  @override
  Widget build(BuildContext context) {
    final figures = [
      _Figure(
        label: AppCopy.outstandingLabel,
        value: money.format(summary.outstanding),
        tone: AppStatusTone.neutral,
      ),
      _Figure(
        label: AppCopy.overdueLabel,
        value: money.format(summary.overdue),
        tone: AppStatusTone.critical,
        badge: summary.overdueCount > 0 ? '${summary.overdueCount}' : null,
      ),
      _Figure(
        label: AppCopy.paidLabel,
        value: money.format(summary.collected),
        tone: AppStatusTone.positive,
      ),
    ];

    final amountStyle = context.textRoles.amountLarge;
    final scaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const gaps = Insets.sm * 2;
        final innerWidth = (constraints.maxWidth - gaps) / 3 - _tilePadding * 2;
        final widest = _widestText(
          [for (final figure in figures) figure.value],
          amountStyle,
          scaler,
        );
        final scale = math.min(1.0, innerWidth * _fitMargin / widest);

        if (context.isCompactWidth || scale < _minSideBySideScale) {
          return Column(
            children: [
              for (var i = 0; i < figures.length; i++) ...[
                if (i > 0) Gap.h8,
                _StackedTile(figure: figures[i], amountStyle: amountStyle),
              ],
            ],
          );
        }

        final sharedStyle = amountStyle.copyWith(
          fontSize: (amountStyle.fontSize ?? 22) * scale,
        );

        // IntrinsicHeight lets the tiles stretch to match each other inside
        // the page's scroll view.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < figures.length; i++) ...[
                if (i > 0) Gap.w8,
                Expanded(
                  child: _SideBySideTile(
                    figure: figures[i],
                    amountStyle: sharedStyle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static double _widestText(
    List<String> values,
    TextStyle style,
    TextScaler scaler,
  ) {
    var widest = 1.0;
    for (final value in values) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      widest = math.max(widest, painter.width);
      painter.dispose();
    }
    return widest;
  }
}

@immutable
class _Figure {
  const _Figure({
    required this.label,
    required this.value,
    required this.tone,
    this.badge,
  });

  final String label;
  final String value;
  final AppStatusTone tone;

  /// A small count beside the label, e.g. how many invoices are overdue.
  final String? badge;
}

class _SideBySideTile extends StatelessWidget {
  const _SideBySideTile({required this.figure, required this.amountStyle});

  final _Figure figure;
  final TextStyle amountStyle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(_SummaryTiles._tilePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _FigureLabel(figure: figure),
          Gap.h8,
          _FullAmount(value: figure.value, style: amountStyle),
        ],
      ),
    );
  }
}

/// A full-width tile with the label on the left and the amount on the right.
class _StackedTile extends StatelessWidget {
  const _StackedTile({required this.figure, required this.amountStyle});

  final _Figure figure;
  final TextStyle amountStyle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.lg,
        vertical: Insets.md,
      ),
      child: Row(
        children: [
          Expanded(child: _FigureLabel(figure: figure)),
          Gap.w12,
          // Only an extreme amount on a tiny screen ever needs shrinking.
          Expanded(
            flex: 2,
            child: _FullAmount(
              value: figure.value,
              style: amountStyle,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}

/// An amount that always shows every digit.
///
/// Laid out at [style]'s size and shrunk only if it still does not fit, so it
/// can never be clipped, faded or ellipsised.
class _FullAmount extends StatelessWidget {
  const _FullAmount({
    required this.value,
    required this.style,
    this.alignment = Alignment.centerLeft,
  });

  final String value;
  final TextStyle style;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(value, style: style, maxLines: 1, softWrap: false),
      ),
    );
  }
}

class _FigureLabel extends StatelessWidget {
  const _FigureLabel({required this.figure});

  final _Figure figure;

  @override
  Widget build(BuildContext context) {
    final badge = figure.badge;
    final colors = context.palette.statusColors(figure.tone);

    return Row(
      children: [
        Flexible(
          child: Text(
            figure.label,
            style: context.text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (badge != null) ...[
          Gap.w4,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.xs,
              vertical: Insets.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: Radii.pillAll,
            ),
            child: Text(
              badge,
              style: context.text.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
