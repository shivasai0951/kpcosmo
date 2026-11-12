import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class EventReportScreen extends StatelessWidget {
  const EventReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/kp-event-analysis'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title
            Text('Marriage Analysis Report', style: AppTypography.heading2),
            const SizedBox(height: 8),
            Text('Comprehensive KP Astrology Analysis', style: AppTypography.bodyLarge.copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: 32),

            // Birth Details Section
            _buildSectionTitle('Birth Details'),
            _buildInfoRow('Name', 'John Doe'),
            _buildInfoRow('DOB', '15/04/1990'),
            _buildInfoRow('TOB', '10:30 AM'),
            _buildInfoRow('Place', 'London, UK'),
            _buildInfoRow('Timezone', 'GMT'),
            const SizedBox(height: 32),

            // Event Status Section
            _buildSectionTitle('Event Analysis Status'),
            _buildStatusRow('Result Status', 'Favorable'),
            _buildStatusRow('Relevant Cusp', '7th House (Libra)'),
            _buildStatusRow('Cusp Sub Lord', 'Saturn'),
            _buildStatusRow('Analysis Confidence', 'High'),
            const SizedBox(height: 32),

            // Supporting Indicators Section
            _buildSectionTitle('Supporting Indicators'),
            _buildInfoRow('Supporting Houses', '2, 7, 11'),
            _buildInfoRow('Opposing Houses', '12'),
            _buildInfoRow('Relevant Sub Lord', 'Saturn'),
            _buildInfoRow('Relevant Sub Lord', 'Saturn'),
            const SizedBox(height: 32),

            // Current DBA Section
            _buildSectionTitle('Current Dasha-Bhukti-Antara'),
            _buildInfoRow('Current Mahadasha', 'Jupiter'),
            _buildInfoRow('Current Bhukti', 'Moon'),
            _buildInfoRow('Current Antara', 'Mercury'),
            _buildInfoRow('Period Active', '01/01/2023 - 01/01/2024'),
            const SizedBox(height: 32),

            // Candidate Periods Section
            _buildSectionTitle('Candidate Favorable Periods'),
            _buildPeriodRow('Period 1', '01/01/2024', '01/01/2026', 'Saturn in 7th house'),
            _buildPeriodRow('Period 2', '01/01/2026', '01/01/2028', 'Saturn retrogradation'),
            const SizedBox(height: 32),

            // Interpretation Limitations Section
            _buildSectionTitle('Interpretation Limitations'),
            _buildInfoRow('Limitations', 'This is a demonstration report - actual calculations would require proper KP rules implementation'),
            _buildInfoRow('Rule Set Version', 'KP Standard v1.0'),
            _buildInfoRow('Calculation Confidence', 'Medium'),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Export PDF
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: AppTypography.heading3.copyWith(color: AppColors.primaryGold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:', style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText)),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:', style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primaryGold),
              ),
              child: Text(value, style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(String period, String from, String to, String reason) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borders),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: Text(period, style: AppTypography.bodyMedium, textAlign: TextAlign.center)),
          Expanded(child: Text(from, style: AppTypography.bodyMedium, textAlign: TextAlign.center)),
          Expanded(child: Text(to, style: AppTypography.bodyMedium, textAlign: TextAlign.center)),
          Expanded(child: Text(reason, style: AppTypography.bodyMedium, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
