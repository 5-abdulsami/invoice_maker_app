/// The seven bundled PDF layouts.
enum InvoiceTemplate {
  template1('Classic'),
  template2('Banner'),
  template3('Corporate'),
  template4('Minimal'),
  template5('Compact'),
  template6('Modern'),
  template7('Elegant');

  const InvoiceTemplate(this.label);

  final String label;

  static InvoiceTemplate fromIndex(int index) =>
      index >= 0 && index < values.length ? values[index] : template1;
}
