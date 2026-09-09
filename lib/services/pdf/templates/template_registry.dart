import 'package:invoicemaker/core/enums/invoice_template.dart';
import 'package:invoicemaker/services/pdf/templates/base_template.dart';
import 'package:invoicemaker/services/pdf/templates/template_1.dart';
import 'package:invoicemaker/services/pdf/templates/template_2.dart';
import 'package:invoicemaker/services/pdf/templates/template_3.dart';
import 'package:invoicemaker/services/pdf/templates/template_4.dart';
import 'package:invoicemaker/services/pdf/templates/template_5.dart';
import 'package:invoicemaker/services/pdf/templates/template_6.dart';
import 'package:invoicemaker/services/pdf/templates/template_7.dart';

/// Maps an [InvoiceTemplate] to the layout that draws it.
sealed class TemplateRegistry {
  static const Map<InvoiceTemplate, BaseTemplate> _templates = {
    InvoiceTemplate.template1: Template1(),
    InvoiceTemplate.template2: Template2(),
    InvoiceTemplate.template3: Template3(),
    InvoiceTemplate.template4: Template4(),
    InvoiceTemplate.template5: Template5(),
    InvoiceTemplate.template6: Template6(),
    InvoiceTemplate.template7: Template7(),
  };

  /// Every template, in picker order.
  static List<BaseTemplate> get all =>
      InvoiceTemplate.values.map(resolve).toList(growable: false);

  /// The layout for [template], falling back to the first one.
  static BaseTemplate resolve(InvoiceTemplate template) =>
      _templates[template] ?? const Template1();
}
