import 'package:invoicemaker/core/enums/document_kind.dart';
import 'package:invoicemaker/data/models/app_settings.dart';

/// Generates the next document number.
///
/// The sequence is stored in settings, so numbering continues correctly after
/// a restart. Numbers already in use are skipped, which matters after a backup
/// is restored or merged and the stored counter has fallen behind.
sealed class DocumentNumbering {
  /// Largest number of sequences to skip before giving up on the pattern.
  static const int _maxProbe = 100000;

  /// The next free number for [kind], and the sequence it came from.
  static ({String number, int sequence}) next({
    required DocumentKind kind,
    required AppSettings settings,
    required Set<String> usedNumbers,
  }) {
    var sequence = settings.sequenceFor(kind);
    if (sequence < 1) sequence = 1;

    for (var probe = 0; probe < _maxProbe; probe++) {
      final candidate = settings.formatNumber(kind, sequence);
      if (!usedNumbers.contains(candidate.trim().toLowerCase())) {
        return (number: candidate, sequence: sequence);
      }
      sequence++;
    }

    return (
      number: settings.formatNumber(kind, sequence),
      sequence: sequence,
    );
  }
}
