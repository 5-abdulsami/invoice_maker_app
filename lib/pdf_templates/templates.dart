import 'dart:typed_data';

import 'package:invoicemaker/model/invoice_model.dart';
import 'package:invoicemaker/pdf_templates/abstract_base_class.dart';
import 'package:invoicemaker/pdf_templates/template_1.dart';
import 'package:invoicemaker/pdf_templates/template_2.dart';
import 'package:invoicemaker/pdf_templates/template_3.dart';
import 'package:invoicemaker/pdf_templates/template_4.dart';
import 'package:invoicemaker/pdf_templates/template_5.dart';
import 'package:invoicemaker/pdf_templates/template_6.dart';
import 'package:invoicemaker/pdf_templates/template_7.dart';

enum InvoiceTemplate {
  template1,
  template2,
  template3,
  template4,
  template5,
  template6,
  template7
}

BaseTemplate getInvoiceTemplateWidget({
  required InvoiceTemplate template,
  required Uint8List signature,
  required Invoice invoice,
  required String action,
}) {
  switch (template) {
    case InvoiceTemplate.template1:
      return Template1(
        signature: signature,
        invoice: invoice,
        action: action,
      );
    case InvoiceTemplate.template2:
      return Template2(
        signature: signature,
        invoice: invoice,
        action: action,
      );
    case InvoiceTemplate.template3:
      return Template3(
        signature: signature,
        invoice: invoice,
        action: action,
      );
    case InvoiceTemplate.template4:
      return Template4(
        signature: signature,
        invoice: invoice,
        action: action,
      );
    case InvoiceTemplate.template5:
      return Template5(
        signature: signature,
        invoice: invoice,
        action: action,
      );
    case InvoiceTemplate.template6:
      return Template6(
        signature: signature,
        invoice: invoice,
        action: action,
      );
    case InvoiceTemplate.template7:
      return Template7(
        signature: signature,
        invoice: invoice,
        action: action,
      );
    default:
      return Template1(
        signature: signature,
        invoice: invoice,
        action: action,
      ); // Default template
  }
}
