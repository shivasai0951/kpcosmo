import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/planetary_position.dart';

class PlanetaryPositionsScreen extends StatelessWidget {
  const PlanetaryPositionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planetary Positions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/kp-chart'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            columns: const [
              DataColumn(label: Text('Planet')),
              DataColumn(label: Text('Rāśi')),
              DataColumn(label: Text('Degree')),
              DataColumn(label: Text('Nakshatra')),
              DataColumn(label: Text('Pada')),
              DataColumn(label: Text('Star Lord')),
              DataColumn(label: Text('Sub Lord')),
              DataColumn(label: Text('House')),
              DataColumn(label: Text('Retro')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Sun')),
                DataCell(Text('Aries')),
                DataCell(Text('14° 23\' 45\"')),
                DataCell(Text('Bharani')),
                DataCell(Text('1')),
                DataCell(Text('Venus')),
                DataCell(Text('Venus')),
                DataCell(Text('1')),
                DataCell(Text('No')),
              ]),
              DataRow(cells: [
                DataCell(Text('Moon')),
                DataCell(Text('Taurus')),
                DataCell(Text('15° 12\' 30\"')),
                DataCell(Text('Rohini')),
                DataCell(Text('2')),
                DataCell(Text('Moon')),
                DataCell(Text('Jupiter')),
                DataCell(Text('2')),
                DataCell(Text('No')),
              ]),
              DataRow(cells: [
                DataCell(Text('Mars')),
                DataCell(Text('Cancer')),
                DataCell(Text('20° 48\' 15\"')),
                DataCell(Text('Ashlesha')),
                DataCell(Text('2')),
                DataCell(Text('Mercury')),
                DataCell(Text('Venus')),
                DataCell(Text('4')),
                DataCell(Text('No')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
