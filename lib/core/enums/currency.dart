/// Currencies the user can bill in.
enum Currency {
  pkr('PKR', 'Rs', 'Rs', 'Pakistani Rupee'),
  usd('USD', r'$', r'$', 'US Dollar'),
  eur('EUR', '€', 'EUR', 'Euro'),
  gbp('GBP', '£', 'GBP', 'British Pound');

  const Currency(this.code, this.symbol, this.pdfSymbol, this.name);

  final String code;

  /// Glyph shown in the app, where the system font covers it.
  final String symbol;

  /// ASCII-safe form used in generated PDFs.
  ///
  /// The built-in PDF fonts are Latin-1 only and cannot draw the euro or
  /// pound signs, so those currencies fall back to their code.
  final String pdfSymbol;

  final String name;

  /// Shown in pickers, e.g. `PKR Rs`.
  String get label => '$code $symbol';

  static Currency fromCode(String code) => values.firstWhere(
        (currency) => currency.code == code,
        orElse: () => Currency.pkr,
      );
}
