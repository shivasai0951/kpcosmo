import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/birth_profile.dart';
import '../../../core/services/profile_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<BirthProfile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final profiles = await DatabaseHelper().getAllBirthProfiles();
      if (mounted) setState(() => _profiles = profiles);
    } catch (_) {}
  }

  Future<void> _deleteProfile(BirthProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete Chart?', style: AppTypography.cardTitle),
        content: Text(
          'Delete "${profile.name}" and all saved chart data? This cannot be undone.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = DatabaseHelper();
    await db.deleteChartCascade(profile.id);
    await db.deleteBirthProfile(profile.id);
    if (ProfileStore.instance.currentProfile?.id == profile.id) {
      ProfileStore.instance.currentProfile = null;
    }
    await _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: const Text('KP Astrology'),
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(
            icon: const Icon(Icons.offline_pin),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offline Mode Active'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardHome(profiles: _profiles, onDelete: _deleteProfile),
          const _ChartsPage(),
          const _ToolsPage(),
          const _SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final List<BirthProfile> profiles;
  final void Function(BirthProfile profile)? onDelete;

  const _DashboardHome({required this.profiles, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Back!', style: AppTypography.heading2),
          const SizedBox(height: 8),
          Text(
            'Your offline KP Astrology companion',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGold, AppColors.lightGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/birth-details'),
              icon: const Icon(Icons.add),
              label: const Text('New Chart / Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.mainBackground,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text('Chart History (Offline)', style: AppTypography.cardTitle),
          const SizedBox(height: 16),

          if (profiles.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.star, size: 64, color: AppColors.primaryGold),
                  const SizedBox(height: 16),
                  Text(
                    'No birth charts saved yet.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/birth-details'),
                    icon: const Icon(Icons.add_chart),
                    label: const Text('Create First Chart'),
                  ),
                ],
              ),
            )
          else
            ...profiles.map((profile) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: AppColors.cardBackground,
                  child: ListTile(
                    leading: const Icon(Icons.star, color: AppColors.primaryGold),
                    title: Text(profile.name, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                    subtitle: Text(
                      '${profile.getFormattedDateOfBirth()} • ${profile.getFormattedTimeOfBirth()} • ${profile.birthplaceName}',
                      style: AppTypography.labelSmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: onDelete == null ? null : () => onDelete!(profile),
                        ),
                      ],
                    ),
                    onTap: () {
                      ProfileStore.instance.currentProfile = profile;
                      context.go('/kp-chart');
                    },
                  ),
                )),
        ],
      ),
    );
  }
}

class _ChartsPage extends StatelessWidget {
  const _ChartsPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Charts Page', style: TextStyle(color: AppColors.primaryText)),
    );
  }
}

class _ToolsPage extends StatelessWidget {
  const _ToolsPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Tools Page', style: TextStyle(color: AppColors.primaryText)),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings Page', style: TextStyle(color: AppColors.primaryText)),
    );
  }
}