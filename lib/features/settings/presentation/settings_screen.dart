import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'system';
  String _selectedLanguage = 'english';
  String _defaultAyanamsa = '23° 45\' 12\"';
  String _houseSystem = 'Placidus';
  String _nodeType = 'Mean';
  String _degreePrecision = 'decimal';
  String _dateFormat = 'DD/MM/YYYY';
  String _timeFormat = '12-hour';
  bool _animationsEnabled = true;
  bool _databaseBackup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionTitle('Appearance'),
            _buildThemeSelector(),
            _buildSectionTitle('General'),
            _buildLanguageSelector(),
            _buildAyanamsaSelector(),
            _buildHouseSystemSelector(),
            _buildNodeTypeSelector(),
            _buildDegreePrecisionSelector(),
            _buildDateFormatSelector(),
            _buildTimeFormatSelector(),
            _buildSectionTitle('Advanced'),
            _buildAnimationsToggle(),
            _buildDatabaseBackupSection(),
            _buildDataManagementSection(),
            _buildAboutSection(),
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

  Widget _buildThemeSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens, color: AppColors.primaryGold),
            title: const Text('Theme'),
            subtitle: Text('$_selectedTheme'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primaryGold),
            title: const Text('Language'),
            subtitle: Text('$_selectedLanguage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAyanamsaSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.star, color: AppColors.primaryGold),
            title: const Text('Default KP Ayanamsa'),
            subtitle: Text(_defaultAyanamsa),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAyanamsaDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseSystemSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primaryGold),
            title: const Text('House System'),
            subtitle: Text(_houseSystem),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHouseSystemDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeTypeSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.primaryGold),
            title: const Text('Node Type'),
            subtitle: Text(_nodeType),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNodeTypeDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildDegreePrecisionSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.straighten, color: AppColors.primaryGold),
            title: const Text('Degree Display Precision'),
            subtitle: Text(_degreePrecision),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDegreePrecisionDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFormatSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.primaryGold),
            title: const Text('Date Format'),
            subtitle: Text(_dateFormat),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDateFormatDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFormatSelector() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.access_time, color: AppColors.primaryGold),
            title: const Text('Time Format'),
            subtitle: Text(_timeFormat),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimeFormatDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationsToggle() {
    return Card(
      color: AppColors.cardBackground,
      child: SwitchListTile(
        title: const Text('Enable Animations'),
        subtitle: const Text('Toggle UI animations and transitions'),
        value: _animationsEnabled,
        onChanged: (value) => setState(() => _animationsEnabled = value),
        secondary: const Icon(Icons.animation, color: AppColors.primaryGold),
      ),
    );
  }

  Widget _buildDatabaseBackupSection() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primaryGold),
            title: const Text('Database Backup'),
            subtitle: const Text('Export your birth chart data to local storage'),
            trailing: Switch(
              value: _databaseBackup,
              onChanged: (value) => setState(() => _databaseBackup = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Column(
      children: [
        Card(
          color: AppColors.cardBackground,
          child: ListTile(
            leading: const Icon(Icons.upload_file, color: AppColors.primaryGold),
            title: const Text('Export Saved Charts'),
            subtitle: const Text('Export all your saved charts and data'),
            onTap: () => _exportAllCharts(),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColors.cardBackground,
          child: ListTile(
            leading: const Icon(Icons.restore_page, color: AppColors.primaryGold),
            title: const Text('Restore Database'),
            subtitle: const Text('Restore data from backup file'),
            onTap: () => _showRestoreDialog(),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: AppColors.cardBackground,
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Clear All History'),
            subtitle: const Text('Delete all birth charts and data'),
            onTap: () => _showClearAllDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Card(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.primaryGold),
            title: const Text('About App'),
            subtitle: const Text('KP Astrology - Version 1.0.0'),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppColors.primaryGold),
            title: const Text('Privacy Policy'),
            subtitle: const Text('View privacy policy and terms of service'),
            onTap: () => _showPrivacyDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.primaryGold),
            title: const Text('License Information'),
            subtitle: const Text('View licensing and attribution information'),
            onTap: () => _showLicenseDialog(),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showThemeDialog() {}
  void _showLanguageDialog() {}
  void _showAyanamsaDialog() {}
  void _showHouseSystemDialog() {}
  void _showNodeTypeDialog() {}
  void _showDegreePrecisionDialog() {}
  void _showDateFormatDialog() {}
  void _showTimeFormatDialog() {}

  // Action methods
  void _exportAllCharts() {}
  void _showRestoreDialog() {}
  void _showClearAllDialog() {}
  void _showAboutDialog() {}
  void _showPrivacyDialog() {}
  void _showLicenseDialog() {}
}
