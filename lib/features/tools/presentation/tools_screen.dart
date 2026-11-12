import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: GridView(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        children: [
          _buildToolCard(context, 'KP 249 Sub Division', Icons.functions, '/tools/kp-249'),
          _buildToolCard(context, 'Nakshatra Finder', Icons.search, '/tools/nakshatra-finder'),
          _buildToolCard(context, 'Planetary Significations', Icons.star, '/tools/planetary-significations'),
          _buildToolCard(context, 'House Significations', Icons.home, '/tools/house-significations'),
          _buildToolCard(context, 'Dasha Calculator', Icons.timeline, '/tools/dasha-calculator'),
          _buildToolCard(context, 'Ruling Planets', Icons.touch_app, '/tools/ruling-planets'),
          _buildToolCard(context, 'Birth Time Sensitivity', Icons.access_time, '/tools/birth-time-sensitivity'),
          _buildToolCard(context, 'KP House Reference', Icons.menu_book, '/tools/kp-house-reference'),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.primaryGold),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.cardTitle.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
