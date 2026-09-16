/// Whether a template is part of the free set or the paid set.
///
/// Tiers are metadata only. Gating lives in `Entitlements`, so billing can be
/// added later without touching the templates themselves.
enum TemplateTier { free, pro }

/// The bundled document layouts.
///
/// Each entry is a structurally different page, not a recolour: they differ in
/// where the header, meta block, party blocks and totals sit, and in how the
/// line-item table is ruled.
enum InvoiceTemplate {
  slate(
    'Slate',
    'Accent rail down the left, quiet ruled table.',
    TemplateTier.free,
  ),
  ledger(
    'Ledger',
    'Formal fully-bordered grid, built for long item lists.',
    TemplateTier.free,
  ),
  banner(
    'Banner',
    'Full-width colour header carrying the logo and title.',
    TemplateTier.free,
  ),
  compact(
    'Compact',
    'Dense single column that fits the most rows per page.',
    TemplateTier.free,
  ),
  statement(
    'Statement',
    'Leads with the amount due, details underneath.',
    TemplateTier.free,
  ),
  column(
    'Column',
    'Contact details in a side column beside the table.',
    TemplateTier.pro,
  ),
  editorial(
    'Editorial',
    'Generous whitespace and large display numerals.',
    TemplateTier.pro,
  ),
  grid(
    'Grid',
    'Every section boxed in its own outlined panel.',
    TemplateTier.pro,
  );

  const InvoiceTemplate(this.label, this.description, this.tier);

  final String label;

  /// One line shown under the name in the template picker.
  final String description;

  final TemplateTier tier;

  bool get isPro => tier == TemplateTier.pro;

  static const InvoiceTemplate fallback = InvoiceTemplate.slate;

  static InvoiceTemplate fromName(String? name) {
    for (final template in values) {
      if (template.name == name) return template;
    }
    return fallback;
  }
}
