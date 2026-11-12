import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/models/birth_profile.dart';
import '../../../../core/services/kp_calculator.dart';
import '../../../../core/services/kp_event_analyzer.dart';
import '../../../../core/services/profile_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Self-contained KP event analysis panel: event/sub-option dropdowns
/// plus the computed result. Used both as a tab inside the chart screen
/// and inside the standalone event analysis screen.
class EventAnalysisPanel extends StatefulWidget {
  const EventAnalysisPanel({super.key});

  @override
  State<EventAnalysisPanel> createState() => _EventAnalysisPanelState();
}

class _EventAnalysisPanelState extends State<EventAnalysisPanel> {
  String _eventType = 'marriage';
  String _subOption = 'Timing';
  CalculatedChart? _chart;
  EventAnalysisResult? _result;
  bool _loading = true;
  String? _error;

  static const _eventTypes = {
    'marriage': 'Marriage',
    'job': 'Job / Service',
    'business': 'Business',
    'vehicle': 'Vehicle Purchase',
    'children': 'Children',
    'property': 'Property Purchase',
  };

  @override
  void initState() {
    super.initState();
    _subOption = KpEventAnalyzer.subOptionsFor(_eventType).first;
    _loadChart();
  }

  Future<void> _loadChart() async {
    try {
      var chart = KpCalculator.lastChart;
      if (chart == null) {
        var profile = ProfileStore.instance.currentProfile;
        profile ??= await _latestProfile();
        if (profile != null) {
          chart = await KpCalculator.loadSaved(profile) ??
              await KpCalculator.calculate(profile);
        }
      }
      if (mounted) {
        setState(() {
          _chart = chart;
          _loading = false;
          if (chart != null) _runAnalysis();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load chart: $e';
        });
      }
    }
  }

  Future<BirthProfile?> _latestProfile() async {
    try {
      final profiles = await DatabaseHelper().getAllBirthProfiles();
      return profiles.isEmpty ? null : profiles.last;
    } catch (_) {
      return null;
    }
  }

  void _runAnalysis() {
    if (_chart == null) return;
    setState(() {
      _result = KpEventAnalyzer.analyze(
        _chart!,
        _eventType,
        subOption: _subOption,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: AppTypography.bodyLarge));
    }
    if (_chart == null) {
      return Center(
        child: Text(
          'No chart found. Create a birth profile first.',
          style: AppTypography.bodyLarge,
        ),
      );
    }
    return _buildContent();
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSelectors(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _result == null ? _buildEmptyState() : _buildResult(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectors() {
    return Container(
      color: AppColors.secondaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Event Type',
              prefixIcon: Icon(Icons.auto_awesome),
              isDense: true,
            ),
            initialValue: _eventType,
            items: _eventTypes.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _eventType = value!;
                _subOption = KpEventAnalyzer.subOptionsFor(_eventType).first;
                _runAnalysis();
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Sub Option',
              prefixIcon: Icon(Icons.tune),
              isDense: true,
            ),
            initialValue: _subOption,
            items: KpEventAnalyzer.subOptionsFor(_eventType)
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _subOption = value!;
                _runAnalysis();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _runAnalysis,
        icon: const Icon(Icons.search),
        label: const Text('Analyze'),
      ),
    );
  }

  Widget _buildResult() {
    final r = _result!;
    final statusColor = _statusColor(r.status);
    final possible = _possibleLabel(r.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline: is the event possible?
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 2),
          ),
          child: Column(
            children: [
              Text(
                'EVENT POSSIBLE?',
                style: AppTypography.labelSmall.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                possible,
                style: AppTypography.heading2.copyWith(color: statusColor),
              ),
              const SizedBox(height: 8),
              Text(
                '${_eventTypes[_eventType] ?? _eventType} — $_subOption',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(r.summary, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 20),

        _sectionTitle('Why?'),
        ...r.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.primaryGold)),
                  Expanded(child: Text(reason, style: AppTypography.bodyMedium)),
                ],
              ),
            )),
        const SizedBox(height: 16),

        _sectionTitle('Event Cusp & Significators'),
        _infoCard([
          'Event House: ${r.eventHouse} (${r.cuspPosition})',
          'Cusp Sub Lord: ${r.cuspSubLord}',
          'Cusp Star Lord: ${r.cuspStarLord}',
          'Cusp Sign Lord: ${r.cuspSignLord}',
          'Significators: ${r.significators.join(', ')}',
          'Supporting Houses: ${r.supportingHouses.isEmpty ? '—' : r.supportingHouses.join(', ')}',
          'Opposing Houses: ${r.opposingHouses.isEmpty ? '—' : r.opposingHouses.join(', ')}',
        ]),
        const SizedBox(height: 16),

        _sectionTitle('All Favorable Timings (DBA)'),
        if (r.candidatePeriods.isEmpty)
          Text('No favorable periods found for this event.', style: AppTypography.bodyMedium)
        else
          ...r.candidatePeriods.map((d) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: AppColors.cardBackground,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    d.level == 'MD' ? Icons.star : Icons.circle_outlined,
                    color: AppColors.primaryGold,
                    size: 18,
                  ),
                  title: Text(
                    '${d.level == 'MD' ? 'Mahadasha' : 'Antardasha'} — ${d.planet}',
                    style: AppTypography.bodyMedium,
                  ),
                  subtitle: Text(
                    '${d.getFormattedStartDate()} – ${d.getFormattedEndDate()}',
                    style: AppTypography.labelSmall,
                  ),
                  trailing: d.isCurrent
                      ? const Text('NOW', style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold))
                      : null,
                ),
              )),
        const SizedBox(height: 16),
      ],
    );
  }

  String _possibleLabel(String status) {
    switch (status) {
      case 'favorable':
        return 'YES';
      case 'unfavorable':
        return 'NO';
      case 'mixed':
        return 'MAYBE';
      default:
        return 'UNCLEAR';
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTypography.cardTitle.copyWith(color: AppColors.primaryGold)),
    );
  }

  Widget _infoCard(List<String> lines) {
    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(line, style: AppTypography.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'favorable':
        return const Color(0xFF48C78E);
      case 'mixed':
        return const Color(0xFFF0B85B);
      case 'unfavorable':
        return const Color(0xFFEF727C);
      default:
        return const Color(0xFF9FA6D2);
    }
  }

}
