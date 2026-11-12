import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/event_analysis_panel.dart';

class KPEventAnalysisScreen extends StatelessWidget {
  const KPEventAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12091F),
      appBar: AppBar(
        title: const Text('Event Analysis (KP)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/kp-chart'),
        ),
      ),
      body: const EventAnalysisPanel(),
    );
  }
}
