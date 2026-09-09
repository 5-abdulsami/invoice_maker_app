import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_spacing.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/enums/estimate_status.dart';
import 'package:invoicemaker/data/models/estimate.dart';
import 'package:invoicemaker/navigation/route_arguments.dart';
import 'package:invoicemaker/navigation/route_names.dart';
import 'package:invoicemaker/presentation/common/dialogs/confirm_dialog.dart';
import 'package:invoicemaker/presentation/common/dialogs/selection_dialog.dart';
import 'package:invoicemaker/presentation/common/widgets/app_drawer.dart';
import 'package:invoicemaker/presentation/common/widgets/empty_state_widget.dart';
import 'package:invoicemaker/presentation/common/widgets/filter_chip_bar.dart';
import 'package:invoicemaker/presentation/common/widgets/search_app_bar.dart';
import 'package:invoicemaker/presentation/estimate/widgets/estimate_card.dart';
import 'package:invoicemaker/providers/estimate_provider.dart';
import 'package:invoicemaker/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// Filter chips on the estimate list; [overdue] is derived from the due date.
enum _EstimateFilter {
  all('All'),
  pending('Pending'),
  approved('Approved'),
  overdue('Overdue'),
  cancelled('Cancel');

  const _EstimateFilter(this.label);

  final String label;

  EstimateStatus? get status => switch (this) {
        _EstimateFilter.pending => EstimateStatus.pending,
        _EstimateFilter.approved => EstimateStatus.approved,
        _EstimateFilter.cancelled => EstimateStatus.cancelled,
        _ => null,
      };
}

/// The estimate tab: filters, search and the estimate list.
class EstimateListScreen extends StatefulWidget {
  const EstimateListScreen({super.key});

  @override
  State<EstimateListScreen> createState() => _EstimateListScreenState();
}

class _EstimateListScreenState extends State<EstimateListScreen> {
  _EstimateFilter _filter = _EstimateFilter.all;
  String _query = '';

  Future<void> _create() async {
    final settings = context.read<SettingsProvider>();
    context.read<EstimateProvider>().resetDraft(
          currency: settings.defaultCurrency,
          dueTermDays: settings.defaultDueTerms,
        );

    await Navigator.of(context).pushNamed(
      RouteNames.createEditEstimate,
      arguments: const CreateEditEstimateArgs(),
    );
  }

  Future<void> _changeStatus(Estimate estimate) async {
    final status = await SelectionDialog.show<EstimateStatus>(
      context,
      title: 'Mark as',
      options: EstimateStatus.values,
      selected: estimate.status,
      labelBuilder: (value) => value.label,
    );
    if (status == null || !mounted) return;
    context.read<EstimateProvider>().setStatus(estimate.id, status);
  }

  Future<void> _delete(Estimate estimate) async {
    final confirmed =
        await ConfirmDialog.show(context, title: 'Delete Estimate');
    if (!confirmed || !mounted) return;
    context.read<EstimateProvider>().removeEstimate(estimate);
  }

  @override
  Widget build(BuildContext context) {
    final estimates = context.watch<EstimateProvider>().filtered(
          status: _filter.status,
          overdueOnly: _filter == _EstimateFilter.overdue,
          query: _query,
        );

    return Scaffold(
      appBar: SearchAppBar(
        title: AppStrings.estimate,
        hintText: 'Search estimates',
        onQueryChanged: (query) => setState(() => _query = query),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilterChipBar<_EstimateFilter>(
              options: _EstimateFilter.values,
              selected: _filter,
              labelBuilder: (filter) => filter.label,
              onSelected: (filter) => setState(() => _filter = filter),
            ),
          ),
          Expanded(
            child: estimates.isEmpty
                ? EmptyStateWidget(
                    message: _query.isEmpty
                        ? AppStrings.noEstimates
                        : 'No estimates match "$_query"',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    itemCount: estimates.length,
                    itemBuilder: (context, index) {
                      final estimate = estimates[index];
                      return EstimateCard(
                        estimate: estimate,
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteNames.estimateDetail,
                          arguments: EstimateDetailArgs(estimate: estimate),
                        ),
                        onLongPress: () => _delete(estimate),
                        onStatusTap: () => _changeStatus(estimate),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppStrings.newEstimate,
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
    );
  }
}
