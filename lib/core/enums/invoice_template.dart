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
  ),
  aurora(
    'Aurora',
    'Edge-to-edge gradient header in teal and indigo.',
    TemplateTier.free,
  ),
  receipt(
    'Receipt',
    'A till-receipt strip in monospace with dashed tear lines.',
    TemplateTier.free,
  ),
  angles(
    'Angles',
    'Bold coral and navy triangles framing the corners.',
    TemplateTier.free,
  ),
  tide(
    'Tide',
    'Soft ocean waves rolling across the top and bottom.',
    TemplateTier.free,
  ),
  sage(
    'Sage',
    'Warm cream paper, sage green and a classic serif.',
    TemplateTier.free,
  ),
  cards(
    'Cards',
    'Friendly rounded cards for every section.',
    TemplateTier.free,
  ),
  duo(
    'Duo',
    'A two-tone split header: title on one side, details on the other.',
    TemplateTier.free,
  ),
  letterhead(
    'Letterhead',
    'Centred business letterhead with a contact strip at the foot.',
    TemplateTier.free,
  ),
  monogram(
    'Monogram',
    'Initials seal, gold rules and a symmetrical serif layout.',
    TemplateTier.pro,
  ),
  blueprint(
    'Blueprint',
    'Engineering graph paper with a technical title block.',
    TemplateTier.pro,
  ),
  spine(
    'Spine',
    'A dark full-height spine with the title running up it.',
    TemplateTier.pro,
  ),
  swiss(
    'Swiss',
    'Strict grid, oversized number and a single red square.',
    TemplateTier.pro,
  ),
  luxe(
    'Luxe',
    'Black and gold with a fine double frame.',
    TemplateTier.pro,
  ),
  poster(
    'Poster',
    'Huge condensed headline in black and signal yellow.',
    TemplateTier.pro,
  ),
  ribbon(
    'Ribbon',
    'A corner ribbon and a bookmark tab carrying the amount.',
    TemplateTier.pro,
  ),
  halftone(
    'Halftone',
    'A fading dot-screen pattern in warm orange.',
    TemplateTier.pro,
  ),
  pinstripe(
    'Pinstripe',
    'Tailored diagonal pinstripes in charcoal and mint.',
    TemplateTier.pro,
  ),
  sheet(
    'Sheet',
    'Spreadsheet-style numbered grid with a formula-bar total.',
    TemplateTier.pro,
  ),
  midnight(
    'Midnight',
    'Deep midnight header with an electric cyan amount.',
    TemplateTier.pro,
  ),
  frame(
    'Frame',
    'A terracotta border wrapping the whole page.',
    TemplateTier.pro,
  ),
  orbit(
    'Orbit',
    'Overlapping circles in plum and rose.',
    TemplateTier.pro,
  ),
  arrow(
    'Arrow',
    'Chevron tabs pointing the way from title to total.',
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
