import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DBAScreen extends StatefulWidget {
  const DBAScreen({super.key});

  @override
  State<DBAScreen> createState() => _DBAScreenState();
}

class _DBAScreenState extends State<DBAScreen> {
  int _selectedPeriodIndex = 0;

  final List<Map<String, dynamic>> _periods = [
    {
      'level': 'Mahadasha',
      'planet': 'Jupiter',
      'start': '01/01/2020',
      'end': '01/01/2032',
      'isActive': true,
    },
    {
      'level': 'Bhukti',
      'planet': 'Moon',
      'start': '01/01/2023',
      'end': '01/01/2024',
      'isActive': false,
    },
    {
      'level': 'Antara',
      'planet': 'Mercury',
      'start': '01/01/2022',
      'end': '01/01/2023',
      'isActive': false,
    },
    {
      'level': 'Sukshma',
      'planet': 'Saturn',
      'start': '01/01/2021',
      'end': '01/01/2022',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vimshottari Dasha Timeline'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/kp-chart'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current period info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.elevatedCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold),
              ),
              child: Column(
                children: [
                  Text('Current Mahadasha', style: AppTypography.cardTitle),
                  const SizedBox(height: 8),
                  Text('Jupiter', style: AppTypography.heading2.copyWith(color: AppColors.primaryGold)),
                  Text('01/01/2020 - 01/01/2032', style: AppTypography.bodyMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.mainBackground, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline
            Column(
              children: [
                for (int index = 0; index < _periods.length; index++) ...[
                  _buildTimelinePeriod(index, _periods[index]),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelinePeriod(int index, Map<String, dynamic> period) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.cardBackground,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: period['isActive'] ? AppColors.primaryGold : AppColors.secondaryText),
                const SizedBox(width: 8),
                Text(
                  '${period['level']} - ${period['planet']}',
                  style: AppTypography.cardTitle.copyWith(
                    color: period['isActive'] ? AppColors.primaryGold : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: period['isActive'] ? AppColors.primaryGold : AppColors.elevatedCard,
                borderRadius: BorderRadius.circular(4),
                border: period['isActive'] ? null : Border.all(color: AppColors.borders),
              ),
              child: Text(
                period['isActive'] ? 'CURRENT' : 'Past',
                style: AppTypography.labelSmall.copyWith(
                  color: period['isActive'] ? AppColors.mainBackground : AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text('${period['start']} - ${period['end']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Details', style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                Text('Planet: ${period['planet']}', style: AppTypography.bodyLarge),
                Text('Level: ${period['level']}', style: AppTypography.bodyLarge),
                Text('Start: ${period['start']}', style: AppTypography.bodyLarge),
                Text('End: ${period['end']}', style: AppTypography.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showPeriodDetails(period),
                  icon: const Icon(Icons.info),
                  label: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodDetails(Map<String, dynamic> period) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Period Details', style: AppTypography.heading2.copyWith(color: AppColors.primaryGold)),
              const SizedBox(height: 16),
              Text('Planet: ${period['planet']}', style: AppTypography.bodyLarge),
              Text('Level: ${period['level']}', style: AppTypography.bodyLarge),
              Text('Start: ${period['start']}', style: AppTypography.bodyLarge),
              Text('End: ${period['end']}', style: AppTypography.bodyLarge),
              Text('Status: ${period['isActive'] ? 'Active' : 'Inactive'}', style: AppTypography.bodyLarge),
            ],
          ),
        );
      },
    );
  }
}
