import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/birth_profile.dart';
import '../../../core/models/planetary_position.dart';
import '../../../core/models/house_cusp.dart';
import '../../../core/models/dasha_period.dart';
import '../../../core/services/kp_calculator.dart';
import '../../../core/services/profile_store.dart';
import 'widgets/south_indian_chart_widget.dart';
import '../../kp_event_analysis/presentation/widgets/event_analysis_panel.dart';

class KPChartScreen extends StatefulWidget {
  const KPChartScreen({super.key});

  @override
  State<KPChartScreen> createState() => _KPChartScreenState();
}

class _KPChartScreenState extends State<KPChartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BirthProfile? _profile;
  CalculatedChart? _chart;
  List<PlanetaryPosition> _planets = [];
  bool _calculating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    var profile = ProfileStore.instance.currentProfile;
    profile ??= await _loadLatestProfile();
    if (!mounted || profile == null) return;

    setState(() {
      _profile = profile;
      _calculating = true;
    });

    try {
      // Prefer the saved offline chart; recalculate only if missing
      var chart = await KpCalculator.loadSaved(profile);
      chart ??= await KpCalculator.calculate(profile);
      final result = chart;
      await KpCalculator.saveChart(profile, result);
      if (mounted) {
        setState(() {
          _chart = result;
          _planets = result.planets;
          _calculating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _calculating = false);
    }
  }

  PlanetaryPosition? get _moonPlanet {
    for (final p in _planets) {
      if (p.planetName == 'Moon') return p;
    }
    return null;
  }

  String get _lagnaStarLord => _chart == null
      ? '—'
      : KpCalculator.starLordFor(_chart!.ascendantLongitude);

  Future<BirthProfile?> _loadLatestProfile() async {
    try {
      final profiles = await DatabaseHelper().getAllBirthProfiles();
      return profiles.isEmpty ? null : profiles.last;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KP Chart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/birth-details'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share PDF/Image
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Text('Export PDF'),
              ),
              const PopupMenuItem(
                value: 'image',
                child: Text('Export Image'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Chart'),
            Tab(text: 'Planets'),
            Tab(text: 'Cusps'),
            Tab(text: 'DBA'),
            Tab(text: 'KP Analysis'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartTab(),
                _buildPlanetsTab(),
                _buildCuspsTab(),
                _buildDBATab(),
                _buildKPAnalysisTab(),
                const EventAnalysisPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.secondaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profile?.name ?? 'No profile selected',
                style: AppTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                _profile != null
                    ? '${_profile!.getFormattedDateOfBirth()} • ${_profile!.getFormattedTimeOfBirth()} • ${_profile!.birthplaceName}'
                    : 'Create a birth profile to see details',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primaryGold),
            ),
            child: Text(
              'KP Ayanamsa',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab() {
    if (_calculating) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_chart == null) {
      return const Center(
        child: Text('No chart calculated yet', style: TextStyle(color: Colors.white)),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SouthIndianChartWidget(
            planets: _planets,
            lagnaSign: KpCalculator.signName(_chart!.ascendantLongitude),
            onPlanetTap: (planet) {
              _showPlanetDetailsBottomSheet(planet);
            },
            onSignTap: (sign) {
              _showSignDetailsBottomSheet(sign);
            },
          ),
          const SizedBox(height: 24),
          _buildChartInfoCard(),
        ],
      ),
    );
  }

  Widget _buildChartInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borders),
      ),
      child: Column(
        children: [
          _buildInfoRow('Lagna (Ascendant)', _chart != null ? KpCalculator.formatPosition(_chart!.ascendantLongitude) : '—'),
          const Divider(),
          _buildInfoRow('Rāśi / Moon Sign', _moonPlanet?.sign ?? '—'),
          const Divider(),
          _buildInfoRow(
            'Janma Nakshatra',
            _moonPlanet != null ? '${_moonPlanet!.nakshatra} (Pada ${_moonPlanet!.pada})' : '—',
          ),
          const Divider(),
          _buildInfoRow('Lagna Star Lord', _lagnaStarLord),
          const Divider(),
          _buildInfoRow('Lagna Sub Lord', _chart != null ? KpCalculator.subLordFor(_chart!.ascendantLongitude) : '—'),
          const Divider(),
          _buildInfoRow('KP Ayanamsa', _chart != null ? '${_chart!.ayanamsa.toStringAsFixed(4)}°' : '—'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText)),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPlanetsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _planets.length,
      itemBuilder: (context, index) {
        final planet = _planets[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: planet.getPlanetColor().withOpacity(0.2),
              child: Text(
                planet.planetName.substring(0, 2),
                style: TextStyle(color: planet.getPlanetColor(), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text('${planet.planetName} ${planet.retrograde ? '(R)' : ''}'),
            subtitle: Text('${planet.sign} • ${planet.getFormattedDegree()} • ${planet.nakshatra}'),
            trailing: Text('House ${planet.houseNumber}'),
            onTap: () => _showPlanetDetailsBottomSheet(planet),
          ),
        );
      },
    );
  }

  Widget _buildCuspsTab() {
    final cusps = _chart?.cusps ?? [];
    if (cusps.isEmpty) {
      return const Center(child: Text('No cusps calculated', style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cusps.length,
      itemBuilder: (context, index) {
        final cusp = cusps[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: AppColors.cardBackground,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGold.withOpacity(0.2),
              child: Text(
                'H${cusp.houseNumber}',
                style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              KpCalculator.formatPosition(cusp.longitude),
              style: AppTypography.cardTitle.copyWith(fontSize: 15),
            ),
            subtitle: Text(
              'Sign Lord: ${cusp.signLord}  •  Star Lord: ${cusp.starLord}  •  Sub Lord: ${cusp.subLord}',
              style: AppTypography.labelSmall,
            ),
            onTap: () => _showCuspDetails(cusp),
          ),
        );
      },
    );
  }

  Widget _buildDBATab() {
    final dashas = _chart?.dashas ?? [];
    if (dashas.isEmpty) {
      return const Center(child: Text('No dasha calculated', style: TextStyle(color: Colors.white)));
    }

    // Group ADs under their parent MD for display
    final mdList = dashas.where((d) => d.level == 'MD').toList();
    final adsByParent = <String, List<DashaPeriod>>{};
    for (final d in dashas.where((d) => d.level == 'AD')) {
      adsByParent.putIfAbsent(d.parentPeriodId ?? '', () => []).add(d);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mdList.length,
      itemBuilder: (context, index) {
        final md = mdList[index];
        final ads = adsByParent[md.id] ?? [];
        final isCurrent = md.isCurrent;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: isCurrent ? AppColors.elevatedCard : AppColors.cardBackground,
          shape: isCurrent
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                )
              : null,
          child: ExpansionTile(
            initiallyExpanded: isCurrent,
            title: Text(
              '${md.planet} Mahadasha',
              style: AppTypography.cardTitle.copyWith(
                color: isCurrent ? AppColors.primaryGold : AppColors.primaryText,
              ),
            ),
            subtitle: Text(
              '${md.getFormattedStartDate()} – ${md.getFormattedEndDate()}'
              '${isCurrent ? '  •  CURRENT' : ''}',
              style: AppTypography.labelSmall,
            ),
            children: [
              for (final ad in ads)
                ListTile(
                  dense: true,
                  leading: Icon(
                    ad.isCurrent ? Icons.circle : Icons.circle_outlined,
                    size: 8,
                    color: ad.isCurrent ? AppColors.primaryGold : AppColors.secondaryText,
                  ),
                  title: Text('${ad.planet} Antardasha', style: AppTypography.bodyMedium),
                  subtitle: Text(
                    '${ad.getFormattedStartDate()} – ${ad.getFormattedEndDate()}',
                    style: AppTypography.labelSmall,
                  ),
                  trailing: ad.isCurrent
                      ? const Text('NOW', style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold))
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPAnalysisTab() {
    if (_chart == null) {
      return const Center(child: Text('No chart calculated', style: TextStyle(color: Colors.white)));
    }

    // KP house significators: occupants + sign lord + cusp star lord + cusp sub lord
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      itemBuilder: (context, index) {
        final houseNum = index + 1;
        final cusp = _chart!.cusps[houseNum - 1];
        final occupants = _planets.where((p) => p.houseNumber == houseNum).toList();

        final houseByPlanet = {for (final p in _planets) p.planetName: p.houseNumber};
        final significatorNames = <String>{
          cusp.signLord,
          cusp.starLord,
          cusp.subLord,
          ...occupants.map((p) => p.planetName),
        }.toList();
        final significators = [
          for (final name in significatorNames)
            '$name (H${houseByPlanet[name] ?? '?'})',
        ];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: AppColors.cardBackground,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('House $houseNum', style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                    Text(
                      KpCalculator.formatPosition(cusp.longitude),
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primaryGold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Occupants: ${occupants.isEmpty ? '—' : occupants.map((p) => p.planetName).join(', ')}',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Significators: ${significators.join(', ')}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCuspDetails(HouseCusp cusp) {
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
              Text(
                'House ${cusp.houseNumber} Cusp',
                style: AppTypography.heading2.copyWith(color: AppColors.primaryGold),
              ),
              const SizedBox(height: 16),
              Text('Position: ${KpCalculator.formatPosition(cusp.longitude)}', style: AppTypography.bodyLarge),
              Text('Sign Lord: ${cusp.signLord}', style: AppTypography.bodyLarge),
              Text('Star Lord: ${cusp.starLord}', style: AppTypography.bodyLarge),
              Text('Sub Lord: ${cusp.subLord}', style: AppTypography.bodyLarge),
            ],
          ),
        );
      },
    );
  }

  void _showPlanetDetailsBottomSheet(PlanetaryPosition planet) {
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
              Text(
                '${planet.planetName} Details',
                style: AppTypography.heading2.copyWith(color: AppColors.primaryGold),
              ),
              const SizedBox(height: 16),
              Text('Sign: ${planet.sign}', style: AppTypography.bodyLarge),
              Text('Degree: ${planet.getFormattedDegree()}', style: AppTypography.bodyLarge),
              Text('Nakshatra: ${planet.nakshatra} (Pada ${planet.pada})', style: AppTypography.bodyLarge),
              Text('Star Lord: ${planet.starLord}', style: AppTypography.bodyLarge),
              Text('Sub Lord: ${planet.subLord}', style: AppTypography.bodyLarge),
              Text('House: ${planet.houseNumber}', style: AppTypography.bodyLarge),
            ],
          ),
        );
      },
    );
  }

  void _showSignDetailsBottomSheet(String sign) {
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
              Text(
                '$sign Sign',
                style: AppTypography.heading2.copyWith(color: AppColors.primaryGold),
              ),
              const SizedBox(height: 16),
              Text('Sign details and lords...', style: AppTypography.bodyLarge),
            ],
          ),
        );
      },
    );
  }
}
