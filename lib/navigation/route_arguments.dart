import 'dart:typed_data';

import 'package:invoicemaker/data/models/client.dart';
import 'package:invoicemaker/data/models/estimate.dart';
import 'package:invoicemaker/data/models/invoice.dart';
import 'package:invoicemaker/data/models/item.dart';

/// Which item form to show, and what the form writes to on save.
enum ItemFormMode {
  /// The reusable item catalogue: name, price, unit and description.
  catalogue,

  /// A line on an invoice: adds quantity, discount, tax and a live amount.
  invoiceLine,

  /// A line on an estimate; same fields as [invoiceLine].
  estimateLine,
}

extension ItemFormModeX on ItemFormMode {
  /// True for the document-line modes, which show the extra pricing fields.
  bool get isLine => this != ItemFormMode.catalogue;
}

/// Opens the catalogue picker that adds a line to a document.
class AddItemArgs {
  const AddItemArgs({this.mode = ItemFormMode.invoiceLine});

  final ItemFormMode mode;
}

/// Opens the invoice form; a null [invoiceId] starts a new invoice.
class CreateEditInvoiceArgs {
  const CreateEditInvoiceArgs({this.invoiceId});

  final String? invoiceId;

  bool get isEditing => invoiceId != null;
}

class InvoiceDetailArgs {
  const InvoiceDetailArgs({required this.invoice});

  final Invoice invoice;
}

class InvoiceInfoArgs {
  const InvoiceInfoArgs({required this.invoice});

  final Invoice invoice;
}

/// Opens the estimate form; a null [estimateId] starts a new estimate.
class CreateEditEstimateArgs {
  const CreateEditEstimateArgs({this.estimateId});

  final String? estimateId;

  bool get isEditing => estimateId != null;
}

class EstimateDetailArgs {
  const EstimateDetailArgs({required this.estimate});

  final Estimate estimate;
}

/// Opens the client form; a null [client] creates one.
class CreateEditClientArgs {
  const CreateEditClientArgs({
    this.client,
    this.selectOnCreate = false,
  });

  final Client? client;

  /// Whether a newly created client becomes the selected one.
  final bool selectOnCreate;

  bool get isEditing => client != null;
}

/// Opens the item form.
class CreateEditItemArgs {
  const CreateEditItemArgs({
    this.item,
    this.mode = ItemFormMode.catalogue,
    this.addToInvoice = false,
  });

  final Item? item;
  final ItemFormMode mode;

  /// True when saving should append a new line rather than update one.
  final bool addToInvoice;

  bool get isEditing => item != null && !addToInvoice;
}

/// Opens the template carousel for [invoice].
class TemplateSelectionArgs {
  const TemplateSelectionArgs({
    required this.invoice,
    required this.signature,
  });

  final Invoice invoice;
  final Uint8List signature;
}

/// Opens the payment method list.
class PaymentMethodArgs {
  const PaymentMethodArgs({this.manageOnly = false});

  /// True when opened from settings, where methods are managed but not picked.
  final bool manageOnly;
}
