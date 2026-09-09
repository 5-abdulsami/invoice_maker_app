/// User facing copy. Keeps wording consistent and easy to change.
sealed class AppStrings {
  static const String appName = 'Invoice Maker';
  static const String tagline = 'Create professional invoices in seconds';

  // Tabs and screen titles
  static const String invoice = 'Invoice';
  static const String estimate = 'Estimate';
  static const String client = 'Client';
  static const String item = 'Item';
  static const String settings = 'Settings';
  static const String report = 'Report';
  static const String sync = 'Sync';
  static const String exportImport = 'Export & Import';
  static const String shareApp = 'Share App';
  static const String businessInfo = 'Business Info';
  static const String paymentMethod = 'Payment Method';
  static const String signature = 'Signature';
  static const String selectTemplate = 'Select Template';

  static const String newInvoice = 'New Invoice';
  static const String editInvoice = 'Edit Invoice';
  static const String invoiceInfo = 'Invoice Info';
  static const String newEstimate = 'New Estimate';
  static const String editEstimate = 'Edit Estimate';
  static const String estimateInfo = 'Estimate Info';
  static const String newClient = 'New Client';
  static const String clientInfo = 'Client Info';
  static const String addClient = 'Add Client';
  static const String newItem = 'New Item';
  static const String editItem = 'Edit Item';
  static const String addItem = 'Add Item';

  // Common actions
  static const String cancel = 'CANCEL';
  static const String save = 'SAVE';
  static const String delete = 'DELETE';
  static const String change = 'CHANGE';
  static const String preview = 'Preview';
  static const String clear = 'Clear';
  static const String share = 'Share';
  static const String print = 'Print';
  static const String sendEmail = 'Send Email';
  static const String comingSoon = 'Coming Soon';

  // Sections
  static const String business = 'Business';
  static const String general = 'General';
  static const String about = 'About';
  static const String from = 'From';
  static const String billTo = 'Bill To';
  static const String items = 'Items';
  static const String subtotal = 'Subtotal';
  static const String discount = 'Discount';
  static const String tax = 'Tax';
  static const String shipping = 'Shipping';
  static const String total = 'Total';
  static const String terms = 'Terms & Conditions';
  static const String currency = 'Currency';
  static const String defaultCurrency = 'Default Currency';
  static const String invoiceLanguage = 'Invoice Language';
  static const String templates = 'Templates';
  static const String dueTerms = 'Due Terms';
  static const String numberFormat = 'Number Format';
  static const String dateFormat = 'Date Format';
  static const String paidShowOnInvoice = 'Paid show on Invoice';
  static const String helpUsTranslate = 'Help Us Translate';
  static const String feedback = 'Feedback';
  static const String privacyPolicy = 'Privacy Policy';
  static const String rateUs = 'Rate Us';

  // Empty and placeholder states
  static const String noClients = 'No Clients';
  static const String noItems = 'No items';
  static const String noInvoices = 'No invoices yet';
  static const String noEstimates = 'No estimates yet';
  static const String noPreview = 'No preview available';
  static const String addBusiness = 'Add Business';
  static const String addSignature = 'Add Signature';
  static const String unknownClient = 'Unknown Client';

  // Messages
  static const String confirmDelete = 'Are you sure to delete your selection?';
  static const String duplicateInvoiceNumber =
      'Invoice number must be unique. Please enter a different invoice number.';
  static const String selectPaymentMethodFirst =
      'Please select a payment method before proceeding.';
  static const String signatureSaveFailed =
      'Failed to save signature. Please try again.';
  static const String shareAppMessage =
      'Enjoy using Invoice Maker? Share with your\nbusiness friends';
  static const String shareAppTitle = 'Share with friends';
  static const String pdfShareText = 'Here is your invoice';
  static const String featureComingSoon =
      'This feature is not available yet. It is coming in a future update.';
}
