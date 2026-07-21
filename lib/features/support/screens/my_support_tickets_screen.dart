import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/features/support/models/support_models.dart';
import 'package:sportheroes_mobile/features/support/providers/support_provider.dart';

class MySupportTicketsScreen extends ConsumerStatefulWidget {
  const MySupportTicketsScreen({super.key});

  @override
  ConsumerState<MySupportTicketsScreen> createState() =>
      _MySupportTicketsScreenState();
}

class _MySupportTicketsScreenState
    extends ConsumerState<MySupportTicketsScreen> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportProvider.notifier).loadMyTickets();
    });
  }

  Color _statusColor(String status) {
    return switch (status) {
      'resolved' || 'closed' => AppColors.success,
      'in_progress' => AppColors.warning700,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportProvider);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(title: const Text('My tickets')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _filterChip(null, 'All'),
                const SizedBox(width: 8),
                _filterChip('open', 'Open'),
                const SizedBox(width: 8),
                _filterChip('in_progress', 'In progress'),
                const SizedBox(width: 8),
                _filterChip('resolved', 'Resolved'),
                const SizedBox(width: 8),
                _filterChip('closed', 'Closed'),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(supportProvider.notifier)
                  .loadMyTickets(status: _statusFilter),
              child: ApiStateView(
                isLoading: state.ticketsState.isLoading,
                error: state.ticketsState.errorOrNull,
                onRetry: () => ref
                    .read(supportProvider.notifier)
                    .loadMyTickets(status: _statusFilter),
                isEmpty:
                    state.tickets.isEmpty && state.ticketsState.isSuccess,
                emptyMessage: 'No support tickets yet.',
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.tickets.length,
                  itemBuilder: (context, i) {
                    final t = state.tickets[i];
                    return _TicketCard(
                      ticket: t,
                      color: _statusColor(t.status),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String? status, String label) {
    final selected = _statusFilter == status;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.primary50,
      checkmarkColor: AppColors.white,
      side: BorderSide.none,
      onSelected: (_) {
        setState(() => _statusFilter = status);
        ref
            .read(supportProvider.notifier)
            .loadMyTickets(status: status);
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.color});

  final SupportTicket ticket;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.ticketNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.statusLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.concern?.label ?? 'Support',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ticket.description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (ticket.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                ticket.createdAt!.split('T').first,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
