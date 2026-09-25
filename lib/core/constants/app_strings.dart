/// Short user-facing labels.
///
/// The app ships in English only; keeping copy here keeps wording consistent
/// and means no screen hardcodes a string.
sealed class AppStrings {
  static const String appName = 'Invoice Maker';
  static const String tagline = 'Invoices and estimates in seconds';

  // Navigation destinations.
  static const String home = 'Home';
  static const String customers = 'Customers';
  static const String catalog = 'Items';
  static const String settings = 'Settings';

  // Primary actions.
  static const String newInvoice = 'New invoice';
  static const String newEstimate = 'New estimate';
  static const String createInvoice = 'Create invoice';
  static const String save = 'Save';
  static const String saveChanges = 'Save changes';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String remove = 'Remove';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String add = 'Add';
  static const String apply = 'Apply';
  static const String close = 'Close';
  static const String retry = 'Try again';
  static const String share = 'Share';
  static const String print = 'Print';
  static const String saveToDevice = 'Save to device';
  static const String duplicate = 'Duplicate';
  static const String preview = 'Preview';
  static const String search = 'Search';
  static const String clear = 'Clear';
  static const String select = 'Select';
  static const String change = 'Change';
  static const String undo = 'Undo';
  static const String learnMore = 'Learn more';
  static const String markAs = 'Mark as';
  static const String convertToInvoice = 'Convert to invoice';

  // Document fields.
  static const String documentNumber = 'Number';
  static const String title = 'Title';
  static const String reference = 'Reference';
  static const String billedTo = 'Billed to';
  static const String billedFrom = 'From';
  static const String lineItems = 'Items';
  static const String quantity = 'Quantity';
  static const String unit = 'Unit';
  static const String unitPrice = 'Unit price';
  static const String price = 'Price';
  static const String description = 'Description';
  static const String discount = 'Discount';
  static const String tax = 'Tax';
  static const String taxLabel = 'Tax name';
  static const String taxRate = 'Tax rate';
  static const String shipping = 'Shipping';
  static const String subtotal = 'Subtotal';
  static const String total = 'Total';
  static const String amountPaid = 'Amount paid';
  static const String balanceDue = 'Balance due';
  static const String notes = 'Notes';
  static const String paymentTerms = 'Payment terms';
  static const String paymentDetails = 'Payment details';
  static const String signature = 'Signature';
  static const String template = 'Template';
  static const String currency = 'Currency';
  static const String status = 'Status';

  // Business and people.
  static const String businessProfile = 'Business profile';
  static const String businessName = 'Business name';
  static const String logo = 'Logo';
  static const String email = 'Email';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String website = 'Website';
  static const String taxNumber = 'Tax / VAT number';
  static const String customerName = 'Customer name';
  static const String newCustomer = 'New customer';
  static const String newItem = 'New item';
  static const String itemName = 'Item name';

  // Settings.
  static const String appearance = 'Appearance';
  static const String theme = 'Theme';
  static const String documentDefaults = 'Document defaults';
  static const String defaultCurrency = 'Default currency';
  static const String defaultTaxRate = 'Default tax rate';
  static const String defaultPaymentTerms = 'Default payment terms';
  static const String numbering = 'Numbering';
  static const String numberFormat = 'Number format';
  static const String dateFormat = 'Date format';
  static const String dataAndBackup = 'Data and backup';
  static const String exportBackup = 'Export a backup';
  static const String importBackup = 'Restore from a backup';
  static const String clearAllData = 'Delete all data';
  static const String about = 'About';
  static const String privacy = 'Privacy';
  static const String privacyPolicy = 'Privacy policy';
  static const String sendFeedback = 'Send feedback';
  static const String rateApp = 'Rate this app';
  static const String version = 'Version';
  static const String upgrade = 'Invoice Maker Pro';
  static const String pro = 'PRO';

  // Filters and sorting.
  static const String all = 'All';
  static const String overdue = 'Overdue';
  static const String sortBy = 'Sort by';
  static const String newestFirst = 'Newest first';
  static const String oldestFirst = 'Oldest first';
  static const String highestAmount = 'Highest amount';
  static const String lowestAmount = 'Lowest amount';
  static const String dueSoonest = 'Due soonest';
}

/// Longer sentences: explanations, empty states and messages.
sealed class AppCopy {
  /// A count with its noun, e.g. `1 invoice`, `3 invoices`.
  ///
  /// Every noun the app counts takes a plain `s` plural.
  static String count(int value, String noun) =>
      '$value ${value == 1 ? noun : '${noun}s'}';

  // Home.
  static const String homeGreeting = 'Your workspace';
  static const String homePrimaryAction = 'Create an invoice';
  static const String homePrimaryHint = 'Bill a customer in a few taps.';
  static const String outstandingLabel = 'Outstanding';
  static const String overdueLabel = 'Overdue';
  static const String paidLabel = 'Paid';
  static const String recentActivity = 'Recent';
  static const String viewAll = 'View all';

  // First run.
  static const String setUpBusinessTitle = 'Add your business details';
  static const String setUpBusinessBody =
      'Your name, logo and contact details appear on every document you '
      'create. You can change them at any time.';
  static const String setUpBusinessAction = 'Add business details';
  static const String skipForNow = 'Skip for now';

  // Empty states.
  static const String noDocumentsTitle = 'No documents yet';
  static const String noDocumentsBody =
      'Create your first invoice and it will appear here.';
  static const String noCustomersTitle = 'No customers yet';
  static const String noCustomersBody =
      'Save the people and companies you bill so you can reuse them.';
  static const String noItemsTitle = 'No saved items';
  static const String noItemsBody =
      'Save the products or services you sell to add them to a document in '
      'one tap.';
  static const String noSearchResultsTitle = 'Nothing found';
  static const String noSearchResultsBody =
      'Try a different name, number or amount.';
  static const String noLinesTitle = 'No items on this document';
  static const String noLinesBody = 'Add at least one item to see a total.';

  // Confirmations.
  static const String deleteDocumentTitle = 'Delete this document?';
  static const String deleteDocumentBody =
      'It will be removed from this device permanently.';
  static const String deleteCustomerTitle = 'Delete this customer?';
  static const String deleteCustomerBody =
      'Documents already created for them keep their own copy of these '
      'details and will not change.';
  static const String deleteItemTitle = 'Delete this saved item?';
  static const String deleteItemBody =
      'Documents that already use it will not change.';
  static const String discardChangesTitle = 'Discard your changes?';
  static const String discardChangesBody = 'This document has unsaved changes.';
  static const String discardAction = 'Discard';
  static const String keepEditingAction = 'Keep editing';

  // Backup.
  static const String backupExplainer =
      'Your data lives only on this device. Export a backup file and keep it '
      'somewhere safe so you can restore it if you change phone.';
  static const String exportBackupBody =
      'Saves every document, customer, saved item and setting into one file.';
  static const String importBackupBody =
      'Reads a backup file created by this app.';
  static const String importMergeTitle = 'How should we restore?';
  static const String importMergeBody =
      'Merging keeps what is on this device and adds anything missing. '
      'Replacing deletes what is here first.';
  static const String importMerge = 'Merge';
  static const String importReplace = 'Replace everything';
  static const String clearAllDataBody =
      'Deletes every document, customer, saved item and your business '
      'profile from this device. Export a backup first if you might want '
      'any of it back.';

  // Privacy.
  static const String privacyBody =
      'Invoice Maker works entirely offline. Your business details, '
      'customers and documents are stored on this device only. Nothing is '
      'uploaded, and the app has no account and collects no analytics. Files '
      'leave the device only when you choose to share, print or export them.';

  // Pro.
  static const String proEarlyAccess =
      'Pro templates are included free while the app is in early access.';

  // Messages.
  static const String savedMessage = 'Saved';
  static const String deletedMessage = 'Deleted';
  static const String duplicatedMessage = 'Copy created';
  static const String documentSavedMessage = 'Document saved';
  static const String backupExportedMessage = 'Backup saved';
  static const String backupImportedMessage = 'Backup restored';
  static const String dataClearedMessage = 'All data deleted';
  static const String pdfSavedMessage = 'PDF saved';
  static const String shareSubject = 'Invoice';

  // Validation.
  static const String requiredField = 'This cannot be empty';
  static const String needsOneItem = 'Add at least one item first';
  static const String needsCustomer = 'Choose who this is for first';
  static const String numberTaken = 'That number is already used';
  static const String invalidAmount = 'Enter a valid amount';
  static const String invalidEmail = 'Enter a valid email address';
  static const String paidAmountTooHigh =
      'The amount paid cannot be more than the total';

  // Failures.
  static const String genericFailure =
      'Something went wrong. Please try again.';
  static const String noPreviewAvailable = 'Preview unavailable';
}
