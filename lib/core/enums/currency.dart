import 'package:invoicemaker/core/utils/number_style.dart';

/// Currencies a user can bill in.
///
/// [symbol] is what appears beside an amount. Codes are used instead of a
/// glyph wherever the glyph is not reliably drawn by the bundled typeface, so
/// an invoice never renders a missing-character box.
enum Currency {
  usd('USD', r'$', 'US Dollar', 2),
  eur('EUR', '€', 'Euro', 2, NumberStyle.dotComma),
  gbp('GBP', '£', 'British Pound', 2),
  inr('INR', '₹', 'Indian Rupee', 2, NumberStyle.lakh),
  jpy('JPY', '¥', 'Japanese Yen', 0),
  pkr('PKR', 'Rs', 'Pakistani Rupee', 0),
  aed('AED', 'AED', 'UAE Dirham', 2),
  sar('SAR', 'SAR', 'Saudi Riyal', 2),
  qar('QAR', 'QAR', 'Qatari Riyal', 2),
  kwd('KWD', 'KWD', 'Kuwaiti Dinar', 3),
  cad('CAD', r'C$', 'Canadian Dollar', 2),
  aud('AUD', r'A$', 'Australian Dollar', 2),
  nzd('NZD', r'NZ$', 'New Zealand Dollar', 2),
  chf('CHF', 'CHF', 'Swiss Franc', 2, NumberStyle.apostropheDot),
  sek('SEK', 'SEK', 'Swedish Krona', 2, NumberStyle.spaceComma),
  nok('NOK', 'NOK', 'Norwegian Krone', 2, NumberStyle.spaceComma),
  zar('ZAR', 'R', 'South African Rand', 2, NumberStyle.spaceComma),
  ngn('NGN', 'NGN', 'Nigerian Naira', 2),
  kes('KES', 'KES', 'Kenyan Shilling', 2),
  egp('EGP', 'EGP', 'Egyptian Pound', 2),
  bdt('BDT', 'BDT', 'Bangladeshi Taka', 2, NumberStyle.lakh),
  lkr('LKR', 'LKR', 'Sri Lankan Rupee', 2),
  npr('NPR', 'NPR', 'Nepalese Rupee', 2, NumberStyle.lakh),
  myr('MYR', 'RM', 'Malaysian Ringgit', 2),
  sgd('SGD', r'S$', 'Singapore Dollar', 2),
  idr('IDR', 'Rp', 'Indonesian Rupiah', 0, NumberStyle.dotComma),
  php('PHP', 'PHP', 'Philippine Peso', 2),
  thb('THB', 'THB', 'Thai Baht', 2),
  vnd('VND', 'VND', 'Vietnamese Dong', 0, NumberStyle.dotComma),
  cny('CNY', 'CNY', 'Chinese Yuan', 2),
  tryLira('TRY', 'TRY', 'Turkish Lira', 2, NumberStyle.dotComma),
  brl('BRL', r'R$', 'Brazilian Real', 2, NumberStyle.dotComma),
  mxn('MXN', r'MX$', 'Mexican Peso', 2),
  ars('ARS', 'ARS', 'Argentine Peso', 2, NumberStyle.dotComma),
  pln('PLN', 'PLN', 'Polish Zloty', 2, NumberStyle.spaceComma);

  const Currency(
    this.code,
    this.symbol,
    this.displayName,
    this.decimalDigits, [
    this.numberStyle = NumberStyle.commaDot,
  ]);

  /// ISO 4217 code, e.g. `USD`.
  final String code;

  /// Prefix shown beside an amount, e.g. `$` or `AED`.
  final String symbol;

  final String displayName;

  /// Minor units this currency is normally written with.
  final int decimalDigits;

  /// How amounts in this currency are conventionally separated, used unless
  /// the user forces one style in settings.
  final NumberStyle numberStyle;

  /// Whether the symbol needs a space before the digits.
  ///
  /// `$1,200` reads correctly but `AED1,200` does not.
  bool get symbolNeedsSpace => symbol.codeUnits.every(_isLetter);

  /// Shown in pickers, e.g. `USD — US Dollar`.
  String get pickerLabel => '$code — $displayName';

  /// Shown where space is tight, e.g. `USD ($)`.
  String get shortLabel => symbolNeedsSpace ? code : '$code ($symbol)';

  static bool _isLetter(int unit) =>
      (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A);

  static const Currency fallback = Currency.usd;

  /// Resolves a stored code, falling back rather than throwing.
  static Currency fromCode(String? code) {
    if (code == null) return fallback;
    for (final currency in values) {
      if (currency.code == code) return currency;
    }
    return fallback;
  }
}
