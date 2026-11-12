import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/birth_details/presentation/birth_details_screen.dart';
import '../../features/kp_chart/presentation/kp_chart_screen.dart';
import '../../features/planetary_positions/presentation/planetary_positions_screen.dart';
import '../../features/house_cusps/presentation/house_cusps_screen.dart';
import '../../features/dasha/presentation/dba_screen.dart';
import '../../features/kp_event_analysis/presentation/kp_event_analysis_screen.dart';
import '../../features/event_report/presentation/event_report_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRouter {
  static GoRouter get routerConfig => GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/birth-details',
        name: 'birth-details',
        builder: (context, state) => const BirthDetailsScreen(),
      ),
      GoRoute(
        path: '/kp-chart',
        name: 'kp-chart',
        builder: (context, state) => const KPChartScreen(),
      ),
      GoRoute(
        path: '/planetary-positions',
        name: 'planetary-positions',
        builder: (context, state) => const PlanetaryPositionsScreen(),
      ),
      GoRoute(
        path: '/house-cusps',
        name: 'house-cusps',
        builder: (context, state) => const HouseCuspsScreen(),
      ),
      GoRoute(
        path: '/dasha',
        name: 'dasha',
        builder: (context, state) => const DBAScreen(),
      ),
      GoRoute(
        path: '/kp-event-analysis',
        name: 'kp-event-analysis',
        builder: (context, state) => const KPEventAnalysisScreen(),
      ),
      GoRoute(
        path: '/event-report',
        name: 'event-report',
        builder: (context, state) => const EventReportScreen(),
      ),
      GoRoute(
        path: '/tools',
        name: 'tools',
        builder: (context, state) => const ToolsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
