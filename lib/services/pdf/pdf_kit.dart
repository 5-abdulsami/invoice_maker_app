import 'package:invoicemaker/data/models/party_snapshot.dart';
import 'package:invoicemaker/services/pdf/pdf_render_data.dart';
import 'package:invoicemaker/services/pdf/pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A column in the line-item table.
enum ItemColumn {
  /// Not named `index`: an enum already has an instance `index`.
  rowNumber('#'),
  item('Item'),
  quantity('Qty'),
  unitPrice('Rate'),
  discount('Disc.'),
  tax('Tax'),
  amount('Amount');

  const ItemColumn(this.heading);

  final String heading;
}

/// Which columns a table shows.
///
/// Columns with nothing in them are dropped, so a simple invoice prints a
/// clean four-column table instead of two columns of zeros.
class ItemTableSpec {
  const ItemTableSpec({required this.columns, this.showDescriptions = true});

  final List<ItemColumn> columns;

  /// Whether a row's description is printed under its name.
  final bool showDescriptions;

  static ItemTableSpec resolve(
    PdfRenderData data, {
    bool showIndex = false,
    bool showDescriptions = true,
    bool allowDiscountColumn = true,
    bool allowTaxColumn = true,
  }) {
    final lines = data.totals.lines;
    final hasRowDiscount = lines.any((line) => line.line.discountPercent > 0);
    final hasRowTax = lines.any((line) => line.taxAmount > 0);

    return ItemTableSpec(
      showDescriptions: showDescriptions,
      columns: [
        if (showIndex) ItemColumn.rowNumber,
        ItemColumn.item,
        ItemColumn.quantity,
        ItemColumn.unitPrice,
        if (allowDiscountColumn && hasRowDiscount) ItemColumn.discount,
        if (allowTaxColumn && hasRowTax) ItemColumn.tax,
        ItemColumn.amount,
      ],
    );
  }

  /// Relative width of each column.
  double weightOf(ItemColumn column) => switch (column) {
        ItemColumn.rowNumber => 0.6,
        ItemColumn.item => 4.4,
        ItemColumn.quantity => 1.1,
        ItemColumn.unitPrice => 1.6,
        ItemColumn.discount => 1.1,
        ItemColumn.tax => 1.1,
        ItemColumn.amount => 1.9,
      };

  pw.Alignment alignmentOf(ItemColumn column) => switch (column) {
        ItemColumn.rowNumber => pw.Alignment.centerLeft,
        ItemColumn.item => pw.Alignment.centerLeft,
        ItemColumn.quantity => pw.Alignment.center,
        ItemColumn.unitPrice ||
        ItemColumn.discount ||
        ItemColumn.tax ||
        ItemColumn.amount =>
          pw.Alignment.centerRight,
      };
}

/// How the item table is ruled.
enum TableStyle {
  /// A hairline under each row only.
  ruledRows,

  /// A full grid, as a formal ledger.
  fullGrid,

  /// Alternate rows washed with the soft accent.
  stripedRows,

  /// A coloured heading band and nothing else.
  headerBand,

  /// No rules at all; spacing does the work.
  open,

  /// A pale accent heading row with accent text, hairlines between rows.
  softHeader,

  /// A heavy accent rule under the heading, hairlines between rows.
  underlineHeader,

  /// Dashed rules between rows, like a till receipt.
  dashed,
}

/// How the grand total is set apart from the rows above it.
enum TotalFinish {
  /// Bold text, no fill.
  plain,

  /// Reversed out of a solid accent bar.
  accentBar,

  /// Accent text on the pale accent wash.
  soft,

  /// Accent text inside an accent outline.
  outlined,

  /// A single rule above and an accountant's double rule below.
  doubleRule,
}

/// Page furniture shared by every template.
///
/// The eight layouts differ in composition — where these blocks sit and which
/// they use — not in their own copies of this code.
sealed class PdfKit {
  static const pw.EdgeInsets _cellPadding = pw.EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 7,
  );

  /// A small all-caps label above a block.
  static pw.Widget sectionLabel(String text, PdfDocTheme theme) =>
      pw.Text(text.toUpperCase(), style: theme.sectionLabel);

  /// The business logo at [size], or nothing when there is none.
  static pw.Widget logo(
    PdfRenderData data, {
    double size = 56,
    pw.BoxFit fit = pw.BoxFit.contain,
  }) {
    final bytes = data.logoBytes;
    if (bytes == null) return pw.SizedBox();

    return pw.SizedBox(
      width: size,
      height: size,
      child: pw.Image(pw.MemoryImage(bytes), fit: fit),
    );
  }

  /// Name and contact details for one side of the document.
  ///
  /// The detail lines are spaced a touch wider than body copy: an address,
  /// phone number and email stacked at body leading read as one grey block.
  static pw.Widget partyBlock({
    required String label,
    required PartySnapshot party,
    required PdfDocTheme theme,
    pw.CrossAxisAlignment align = pw.CrossAxisAlignment.start,
    bool showLabel = true,
    pw.TextStyle? labelStyle,
    pw.TextStyle? nameStyle,
    pw.TextStyle? textStyle,
  }) {
    final textAlign = switch (align) {
      pw.CrossAxisAlignment.end => pw.TextAlign.right,
      pw.CrossAxisAlignment.center => pw.TextAlign.center,
      _ => pw.TextAlign.left,
    };
    final details = party.detailLines;

    return pw.Column(
      crossAxisAlignment: align,
      children: [
        if (showLabel) ...[
          pw.Text(
            label.toUpperCase(),
            style: labelStyle ?? theme.sectionLabel,
            textAlign: textAlign,
          ),
          pw.SizedBox(height: 6),
        ],
        pw.Text(
          party.name.trim().isEmpty ? '-' : party.name.trim(),
          style: nameStyle ?? theme.partyName,
          textAlign: textAlign,
        ),
        if (details.isNotEmpty) pw.SizedBox(height: 4),
        for (var i = 0; i < details.length; i++) ...[
          if (i > 0) pw.SizedBox(height: 3.5),
          pw.Text(
            details[i],
            style: textStyle ?? theme.bodyText,
            textAlign: textAlign,
          ),
        ],
      ],
    );
  }

  /// Label/value pairs, e.g. the number and dates.
  static pw.Widget metaRows(
    List<({String label, String value})> rows,
    PdfDocTheme theme, {
    bool onAccent = false,
    pw.CrossAxisAlignment align = pw.CrossAxisAlignment.end,
    double labelWidth = 74,
    PdfColor? labelColor,
    PdfColor? valueColor,
  }) {
    final labelStyle = theme.bodyText.copyWith(
      color: labelColor ?? (onAccent ? theme.onAccent : theme.muted),
    );
    final valueStyle = theme.bodyStrong.copyWith(
      color: valueColor ?? (onAccent ? theme.onAccent : theme.ink),
    );

    return pw.Column(
      crossAxisAlignment: align,
      children: [
        for (final row in rows)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2.5),
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.SizedBox(
                  width: labelWidth,
                  child: pw.Text(
                    row.label,
                    style: labelStyle,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(row.value, style: valueStyle),
              ],
            ),
          ),
      ],
    );
  }

  /// The meta rows as one horizontal strip of label-over-value cells.
  static pw.Widget metaStrip(
    List<({String label, String value})> rows,
    PdfDocTheme theme, {
    PdfColor? labelColor,
    PdfColor? valueColor,
    PdfColor? dividerColor,
    PdfColor? topRuleColor,
    double topRuleWidth = 1.5,
    pw.TextStyle? valueStyle,
    bool centered = false,
  }) {
    final align =
        centered ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start;
    final label = theme.sectionLabel.copyWith(color: labelColor);
    final value = (valueStyle ?? theme.bodyStrong).copyWith(color: valueColor);

    pw.Widget cell(({String label, String value}) row) {
      final content = pw.Column(
        crossAxisAlignment: align,
        children: [
          pw.Text(row.label.toUpperCase(), style: label, maxLines: 1),
          pw.SizedBox(height: 5),
          pw.Text(row.value, style: value, maxLines: 2),
        ],
      );
      if (topRuleColor == null) return content;
      return pw.Container(
        padding: const pw.EdgeInsets.only(top: 7),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: topRuleColor, width: topRuleWidth),
          ),
        ),
        child: content,
      );
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            dividerColor == null
                ? pw.SizedBox(width: 14)
                : pw.Container(
                    width: 0.6,
                    height: 26,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 12),
                    color: dividerColor,
                  ),
          pw.Expanded(child: cell(rows[i])),
        ],
      ],
    );
  }

  /// The line-item table.
  ///
  /// The heading row repeats on every page, so a document that spills onto a
  /// second page still has labelled columns.
  static pw.Widget itemTable({
    required PdfRenderData data,
    required PdfDocTheme theme,
    required ItemTableSpec spec,
    TableStyle style = TableStyle.ruledRows,
    PdfColor? headerFill,
    PdfColor? headerText,
    PdfColor? stripeFill,
    PdfColor? rowFill,
  }) {
    final columns = spec.columns;
    if (data.totals.lines.isEmpty) return _emptyTableNote(theme);

    final headerOnAccent = style == TableStyle.headerBand ||
        style == TableStyle.fullGrid ||
        style == TableStyle.stripedRows;
    final headerStyle = headerText != null
        ? theme.tableHeader.copyWith(color: headerText)
        : switch (style) {
            TableStyle.softHeader ||
            TableStyle.underlineHeader =>
              theme.tableHeader.copyWith(color: theme.accent),
            _ when headerOnAccent => theme.tableHeaderOnAccent,
            _ => theme.tableHeader,
          };

    return pw.Table(
      columnWidths: {
        for (var i = 0; i < columns.length; i++)
          i: pw.FlexColumnWidth(spec.weightOf(columns[i])),
      },
      border: _borderFor(style, theme),
      children: [
        pw.TableRow(
          repeat: true,
          decoration: pw.BoxDecoration(
            color: headerFill ??
                switch (style) {
                  TableStyle.headerBand ||
                  TableStyle.fullGrid ||
                  TableStyle.stripedRows =>
                    theme.accent,
                  TableStyle.softHeader => theme.accentSoft,
                  TableStyle.ruledRows ||
                  TableStyle.open ||
                  TableStyle.underlineHeader ||
                  TableStyle.dashed =>
                    null,
                },
            border: style == TableStyle.underlineHeader
                ? pw.Border(
                    bottom: pw.BorderSide(color: theme.accent, width: 1.6),
                  )
                : null,
          ),
          children: [
            for (final column in columns)
              _cell(
                alignment: spec.alignmentOf(column),
                child: pw.Text(
                  column == ItemColumn.amount
                      ? '${column.heading} (${data.moneyFormat.currency.code})'
                      : column.heading,
                  style: headerStyle,
                ),
              ),
          ],
        ),
        for (var index = 0; index < data.totals.lines.length; index++)
          pw.TableRow(
            decoration: style == TableStyle.stripedRows && index.isOdd
                ? pw.BoxDecoration(color: stripeFill ?? theme.accentSoft)
                : rowFill == null
                    ? null
                    : pw.BoxDecoration(color: rowFill),
            children: [
              for (final column in columns)
                _cell(
                  alignment: spec.alignmentOf(column),
                  child: _cellContent(
                    column: column,
                    index: index,
                    data: data,
                    theme: theme,
                    showDescription: spec.showDescriptions,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _cellContent({
    required ItemColumn column,
    required int index,
    required PdfRenderData data,
    required PdfDocTheme theme,
    required bool showDescription,
  }) {
    final total = data.totals.lines[index];
    final line = total.line;

    return switch (column) {
      ItemColumn.rowNumber => pw.Text('${index + 1}', style: theme.tableNumber),
      ItemColumn.item => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              line.name.trim().isEmpty ? '-' : line.name.trim(),
              style: theme.tableCell,
            ),
            if (showDescription && line.description.trim().isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text(line.description.trim(), style: theme.tableCellMuted),
            ],
          ],
        ),
      ItemColumn.quantity =>
        pw.Text(line.quantityWithUnit, style: theme.tableNumber),
      ItemColumn.unitPrice =>
        pw.Text(data.money(line.unitPrice), style: theme.tableNumber),
      ItemColumn.discount => pw.Text(
          line.discountPercent > 0 ? data.percent(line.discountPercent) : '-',
          style: theme.tableNumber,
        ),
      ItemColumn.tax => pw.Text(
          total.taxPercent > 0 ? data.percent(total.taxPercent) : '-',
          style: theme.tableNumber,
        ),
      ItemColumn.amount =>
        pw.Text(data.money(total.netAmount), style: theme.tableNumberStrong),
    };
  }

  static pw.Widget _cell({
    required pw.Widget child,
    required pw.Alignment alignment,
  }) {
    return pw.Padding(
      padding: _cellPadding,
      child: pw.Align(alignment: alignment, child: child),
    );
  }

  static pw.TableBorder? _borderFor(TableStyle style, PdfDocTheme theme) {
    final hairline = pw.BorderSide(color: theme.hairline, width: 0.5);
    final strong = pw.BorderSide(color: theme.ink, width: 0.8);

    return switch (style) {
      TableStyle.fullGrid => pw.TableBorder(
          top: hairline,
          bottom: hairline,
          left: hairline,
          right: hairline,
          horizontalInside: hairline,
          verticalInside: hairline,
        ),
      // The heading sits above the first inside rule, so `horizontalInside`
      // is what underlines it.
      TableStyle.ruledRows => pw.TableBorder(
          top: strong,
          bottom: hairline,
          horizontalInside: hairline,
        ),
      TableStyle.headerBand => pw.TableBorder(horizontalInside: hairline),
      TableStyle.softHeader || TableStyle.underlineHeader => pw.TableBorder(
          horizontalInside: hairline,
          bottom: hairline,
        ),
      TableStyle.dashed => pw.TableBorder(
          top: _dash(theme.muted),
          bottom: _dash(theme.muted),
          horizontalInside: _dash(theme.hairline),
        ),
      TableStyle.stripedRows || TableStyle.open => null,
    };
  }

  static pw.BorderSide _dash(PdfColor color) => pw.BorderSide(
        color: color,
        width: 0.6,
        style: pw.BorderStyle.dashed,
      );

  /// A dashed horizontal rule, like the tear lines on a receipt.
  static pw.Widget dashedRule(PdfColor color, {double width = 0.6}) {
    return pw.Container(
      height: 0,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: color,
            width: width,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
    );
  }

  /// Both parties side by side, the customer first unless [issuerFirst].
  static pw.Widget parties(
    PdfRenderData data,
    PdfDocTheme theme, {
    String toLabel = 'Billed to',
    String fromLabel = 'From',
    bool issuerFirst = false,
    bool alignSecondEnd = false,
    double gap = 28,
    pw.TextStyle? labelStyle,
    pw.TextStyle? nameStyle,
    pw.TextStyle? textStyle,
  }) {
    pw.Widget block(String label, PartySnapshot party, bool end) => partyBlock(
          label: label,
          party: party,
          theme: theme,
          align: end ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
          labelStyle: labelStyle,
          nameStyle: nameStyle,
          textStyle: textStyle,
        );

    final to = (toLabel, data.document.recipient);
    final from = (fromLabel, data.document.issuer);
    final (first, second) = issuerFirst ? (from, to) : (to, from);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: block(first.$1, first.$2, false)),
        pw.SizedBox(width: gap),
        pw.Expanded(child: block(second.$1, second.$2, alignSecondEnd)),
      ],
    );
  }

  /// The totals block on the right, with the paid marker opposite it.
  static pw.Widget summary(
    PdfRenderData data,
    PdfDocTheme theme, {
    TotalFinish finish = TotalFinish.plain,
    double width = 250,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (data.isSettledInvoice) PdfKit.paidMarker(data, theme),
        pw.Spacer(),
        pw.SizedBox(
          width: width,
          child: totalsRows(data: data, theme: theme, finish: finish),
        ),
      ],
    );
  }

  /// Payment details, terms and notes beside the signature.
  static pw.Widget closing(PdfRenderData data, PdfDocTheme theme) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: closingBlocks(data: data, theme: theme)),
        if (data.hasSignature) ...[
          pw.SizedBox(width: 24),
          signatureBlock(data: data, theme: theme),
        ],
      ],
    );
  }

  /// Whether the document carries any payment details, terms or notes.
  static bool hasClosing(PdfRenderData data) {
    final document = data.document;
    return document.paymentDetails.trim().isNotEmpty ||
        document.paymentTerms.trim().isNotEmpty ||
        document.notes.trim().isNotEmpty;
  }

  /// A line of text centred across the full content width.
  static pw.Widget centered(String text, pw.TextStyle style) => pw.SizedBox(
        width: double.infinity,
        child: pw.Text(text, style: style, textAlign: pw.TextAlign.center),
      );

  /// Up to two initials from [name], for monogram marks.
  static String initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '-';
    final letters =
        words.take(2).map((word) => String.fromCharCode(word.runes.first));
    return letters.join().toUpperCase();
  }

  /// The issuer's contact details on one line, for letterheads and strips.
  static String contactLine(
    PartySnapshot party, {
    String separator = '  ·  ',
  }) =>
      party.detailLines
          .map((line) => line.replaceAll(RegExp(r'\s*\n\s*'), ', '))
          .join(separator);

  /// A thin horizontal rule.
  static pw.Widget rule(PdfDocTheme theme, {double? width, PdfColor? color}) =>
      pw.Container(
        width: width,
        height: 0.5,
        color: color ?? theme.hairline,
      );

  static pw.Widget _emptyTableNote(PdfDocTheme theme) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 18),
        alignment: pw.Alignment.center,
        child: pw.Text('No items on this document', style: theme.caption),
      );

  /// The subtotal, discount, tax, shipping and total rows.
  ///
  /// Rows that would read as zero are left out, so the block stays short on a
  /// simple document and complete on a complex one.
  static pw.Widget totalsRows({
    required PdfRenderData data,
    required PdfDocTheme theme,
    bool emphasiseTotal = true,
    bool totalOnAccent = false,
    TotalFinish? finish,
  }) {
    final resolvedFinish =
        finish ?? (totalOnAccent ? TotalFinish.accentBar : TotalFinish.plain);
    final totals = data.totals;
    final document = data.document;

    final discountLabel = totals.discount.isPercent && totals.hasDiscount
        ? 'Discount (${data.percent(totals.discount.value)})'
        : 'Discount';

    final taxName =
        document.taxLabel.trim().isEmpty ? 'Tax' : document.taxLabel.trim();
    final uniformRate = totals.uniformTaxRate;
    final taxLabel = uniformRate != null && uniformRate > 0
        ? '$taxName (${data.percent(uniformRate)})'
        : taxName;

    return pw.Column(
      children: [
        _totalsRow('Subtotal', data.money(totals.subtotal), theme),
        if (totals.hasDiscount)
          _totalsRow(
            discountLabel,
            data.moneyNegated(totals.discountAmount),
            theme,
          ),
        if (totals.hasTax)
          _totalsRow(taxLabel, data.money(totals.taxAmount), theme),
        if (totals.hasShipping)
          _totalsRow('Shipping', data.money(totals.shipping), theme),
        pw.SizedBox(height: 6),
        switch (resolvedFinish) {
          TotalFinish.plain => _totalsRow(
              'Total',
              data.money(totals.total),
              theme,
              isTotal: emphasiseTotal,
            ),
          TotalFinish.accentBar => _accentTotal(data, theme),
          TotalFinish.soft => _accentTotal(
              data,
              theme,
              fill: theme.accentSoft,
              text: theme.accent,
            ),
          TotalFinish.outlined => pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: theme.accent, width: 1.2),
              ),
              child: _totalsRow(
                'Total',
                data.money(totals.total),
                theme,
                isTotal: true,
                color: theme.accent,
              ),
            ),
          TotalFinish.doubleRule => pw.Column(
              children: [
                rule(theme, color: theme.ink),
                pw.SizedBox(height: 4),
                _totalsRow(
                  'Total',
                  data.money(totals.total),
                  theme,
                  isTotal: true,
                ),
                pw.SizedBox(height: 3),
                rule(theme, color: theme.ink),
                pw.SizedBox(height: 1.5),
                rule(theme, color: theme.ink),
              ],
            ),
        },
        if (document.isInvoice && totals.hasPayment) ...[
          pw.SizedBox(height: 4),
          _totalsRow('Paid', data.moneyNegated(totals.amountPaid), theme),
          _totalsRow(
            'Balance due',
            data.money(totals.balanceDue),
            theme,
            isTotal: true,
          ),
        ],
      ],
    );
  }

  static pw.Widget _totalsRow(
    String label,
    String value,
    PdfDocTheme theme, {
    bool isTotal = false,
    PdfColor? color,
  }) {
    final labelStyle = isTotal ? theme.grandTotalLabel : theme.totalsLabel;
    final valueStyle = isTotal ? theme.grandTotalValue : theme.totalsValue;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: labelStyle.copyWith(color: color),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Text(
            value,
            style: valueStyle.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  static pw.Widget _accentTotal(
    PdfRenderData data,
    PdfDocTheme theme, {
    PdfColor? fill,
    PdfColor? text,
  }) {
    final onFill = text ?? theme.onAccent;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: fill ?? theme.accent,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Text(
              'Total',
              style: theme.grandTotalLabel.copyWith(color: onFill),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Text(
            data.money(data.totals.total),
            style: theme.grandTotalValue.copyWith(color: onFill),
          ),
        ],
      ),
    );
  }

  /// A labelled paragraph, used for notes, terms and payment details.
  static pw.Widget textBlock({
    required String label,
    required String body,
    required PdfDocTheme theme,
    double maxWidth = double.infinity,
  }) {
    if (body.trim().isEmpty) return pw.SizedBox();

    return pw.Container(
      width: maxWidth == double.infinity ? null : maxWidth,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          sectionLabel(label, theme),
          pw.SizedBox(height: 3),
          pw.Text(body.trim(), style: theme.bodyText),
        ],
      ),
    );
  }

  /// Every closing block a document may carry, laid out in one column.
  static pw.Widget closingBlocks({
    required PdfRenderData data,
    required PdfDocTheme theme,
    double? maxWidth,
  }) {
    final document = data.document;
    final blocks = <pw.Widget>[
      if (document.paymentDetails.trim().isNotEmpty)
        textBlock(
          label: 'Payment details',
          body: document.paymentDetails,
          theme: theme,
        ),
      if (document.paymentTerms.trim().isNotEmpty)
        textBlock(
          label: 'Payment terms',
          body: document.paymentTerms,
          theme: theme,
        ),
      if (document.notes.trim().isNotEmpty)
        textBlock(label: 'Notes', body: document.notes, theme: theme),
    ];

    if (blocks.isEmpty) return pw.SizedBox();

    return pw.Container(
      width: maxWidth,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < blocks.length; i++) ...[
            if (i > 0) pw.SizedBox(height: 10),
            blocks[i],
          ],
        ],
      ),
    );
  }

  /// The signature image over a ruled line, or nothing when unsigned.
  static pw.Widget signatureBlock({
    required PdfRenderData data,
    required PdfDocTheme theme,
    double width = 130,
  }) {
    final bytes = data.signatureBytes;
    if (bytes == null) return pw.SizedBox();

    return pw.Column(
      children: [
        pw.SizedBox(
          width: width,
          height: 42,
          child: pw.Image(pw.MemoryImage(bytes)),
        ),
        rule(theme, width: width),
        pw.SizedBox(height: 3),
        pw.SizedBox(
          width: width,
          child: pw.Text(
            'Authorised signature',
            style: theme.caption,
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// A "paid in full" marker for a settled invoice.
  static pw.Widget paidMarker(PdfRenderData data, PdfDocTheme theme) {
    if (!data.isSettledInvoice) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: theme.accent),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(
        'PAID IN FULL',
        style: pw.TextStyle(
          font: theme.fonts.narrowBold,
          fontSize: 9,
          color: theme.accent,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// The page footer: the issuer's name on the left, page count on the right.
  static pw.Widget pageFooter(
    pw.Context context,
    PdfRenderData data,
    PdfDocTheme theme,
  ) {
    final name = data.document.issuer.name.trim();

    return pw.Column(
      children: [
        rule(theme),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                name.isEmpty ? data.document.number : name,
                style: theme.footerText,
                maxLines: 1,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: theme.footerText,
            ),
          ],
        ),
      ],
    );
  }

  /// Standard A4 page settings for a template.
  ///
  /// [background] paints edge to edge behind the content of every page, for
  /// the bands, frames and patterns that should run off the paper's edge.
  static pw.PageTheme pageTheme(
    PdfDocTheme theme, {
    pw.EdgeInsets margin = const pw.EdgeInsets.fromLTRB(36, 36, 36, 30),
    pw.Widget Function(pw.Context context)? background,
  }) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      margin: margin,
      theme: theme.pageTheme,
      buildBackground: background == null
          ? null
          : (context) => pw.FullPage(
                ignoreMargins: true,
                child: background(context),
              ),
    );
  }
}
