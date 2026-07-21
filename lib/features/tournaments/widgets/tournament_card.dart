import 'package:flutter/material.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.name,
    required this.sport,
    required this.format,
    required this.status,
    required this.participants,
    required this.venue,
    required this.dateRange,
    this.onTap,
  });

  final String name;
  final String sport;
  final String format;
  final String status;
  final int participants;
  final String venue;
  final String dateRange;
  final VoidCallback? onTap;

  Color get _statusColor {
    final s = status.toLowerCase();
    if (s.contains('ongoing')) return AppColors.success;
    if (s.contains('registration')) return AppColors.info;
    if (s.contains('completed') || s.contains('cancelled')) {
      return AppColors.grey500;
    }
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('$sport · $format'),
              const SizedBox(height: 4),
              Text(
                participants > 0
                    ? 'Max $participants · $venue'
                    : venue,
              ),
              const SizedBox(height: 4),
              Text(
                dateRange,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
