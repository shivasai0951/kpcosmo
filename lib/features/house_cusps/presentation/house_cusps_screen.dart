import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/birth_profile.dart';
import '../../../core/models/house_cusp.dart';
import '../../../core/services/kp_calculator.dart';
import '../../../core/services/profile_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HouseCuspsScreen extends StatefulWidget {
  const HouseCuspsScreen({super.key});

  @override
  State<HouseCuspsScreen> createState() => _HouseCuspsScreenState();
}

class _HouseCuspsScreenState extends State<HouseCuspsScreen> {
  List<HouseCusp> _cusps = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCusps();
  }

  Future<void> _loadCusps() async {
    try {
      var profile = ProfileStore.instance.currentProfile;
      profile ??= await _loadLatestProfile();
      if (profile == null) {
        setState(() {
          _loading = false;
          _error = 'No birth profile found. Create a chart first.';
        });
        return;
      }

      final chart = await KpCalculator.calculate(profile);
      if (mounted) {
        setState(() {
          _cusps = chart.cusps;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not calculate cusps: $e';
        });
      }
    }
  }

  Future<BirthProfile?> _loadLatestProfile() async {
    try {
      final profiles = await DatabaseHelper().getAllBirthProfiles();
      return profiles.isEmpty ? null : profiles.last;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Cusps'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/kp-chart'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, style: AppTypography.bodyLarge),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final cusp in _cusps)
                        _buildCuspCard(
                          context,
                          cusp.houseNumber,
                          '${_houseTitle(cusp.houseNumber)} House',
                          KpCalculator.formatPosition(cusp.longitude),
                          cusp.signLord,
                          cusp.starLord,
                          cusp.subLord,
                        ),
                    ],
                  ),
                ),
    );
  }

  String _houseTitle(int n) {
    const titles = [
      '1st', '2nd', '3rd', '4th', '5th', '6th',
      '7th', '8th', '9th', '10th', '11th', '12th',
    ];
    return titles[n - 1];
  }

  Widget _buildCuspCard(BuildContext context, int houseNumber, String houseTitle, String degreeSign, String signLord, String starLord, String subLord) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.cardBackground,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'H$houseNumber',
            style: AppTypography.cardTitle.copyWith(fontSize: 14, color: AppColors.primaryGold),
          ),
        ),
        title: Text(houseTitle, style: AppTypography.cardTitle),
        subtitle: Text('$degreeSign • Sign Lord: $signLord • Star Lord: $starLord • Sub Lord: $subLord'),
        trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => _showCuspDetails(context, houseNumber, degreeSign, signLord, starLord, subLord),
        ),
      ),
    );
  }

  void _showCuspDetails(BuildContext context, int houseNumber, String degreeSign, String signLord, String starLord, String subLord) {
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
              Text('Cusp $houseNumber Details', style: AppTypography.heading2.copyWith(color: AppColors.primaryGold)),
              const SizedBox(height: 16),
              Text('Degree: $degreeSign', style: AppTypography.bodyLarge),
              Text('Sign Lord: $signLord', style: AppTypography.bodyLarge),
              Text('Star Lord: $starLord', style: AppTypography.bodyLarge),
              Text('Sub Lord: $subLord', style: AppTypography.bodyLarge),
            ],
          ),
        );
      },
    );
  }
}
