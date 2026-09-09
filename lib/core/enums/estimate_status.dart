/// Lifecycle state of an estimate.
enum EstimateStatus {
  pending('Pending'),
  approved('Approved'),
  cancelled('Cancel');

  const EstimateStatus(this.label);

  final String label;

  static EstimateStatus fromLabel(String label) => values.firstWhere(
        (status) => status.label == label,
        orElse: () => EstimateStatus.pending,
      );
}
