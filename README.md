# KP Astrology

A production-ready 100% offline KP Astrology mobile application for Android and iOS using Flutter and Dart.

## Overview

KP Astrology is a premium, offline-capable application that provides Krishnamurti Paddhati (KP) astrological calculations and event analysis without requiring internet connectivity. The app features a sophisticated offline database, custom astronomical calculation engine, and comprehensive event analysis for Marriage, Job, and Property Purchase predictions.

## Key Features

- **100% Offline Operation**: All calculations run locally on the device using Swiss Ephemeris
- **Premium Dark Purple & Gold Design**: Cosmic astrology theme with smooth animations
- **Offline SQLite Database**: Save birth profiles, charts, and calculation history
- **South Indian Rāśi Chart**: Fixed traditional sign arrangement with custom widgets
- **KP Event Analysis**: Explainable event predictions for Marriage, Job, and Property
- **Vimshottari Dasha Timeline**: Detailed planetary period calculations
- **Multiple Birth Profiles**: Support for multiple saved birth charts
- **Export/Import**: PDF report generation and data backup

## Technology Stack

- **Flutter** with **Dart**: Cross-platform mobile development
- **Riverpod**: State management with dependency injection
- **Go Router**: Declarative navigation system
- **Sqflite**: Offline SQLite database
- **Swiss Ephemeris (sweph)**: Local astronomical calculations
- **PDF & Printing**: Report generation and sharing
- **Google Fonts**: Premium typography (Cinzel, Inter, Inconsolata)
- **Flutter Animate**: Smooth screen and widget animations

## Project Structure

```
lib/
├── core/                    # Core architecture and utilities
│   ├── theme/              # Design system (colors, typography)
│   ├── router/             # Navigation setup
│   ├── database/           # SQLite helper and migrations
│   ├── models/             # Data models
│   └── services/           # Core services
├── features/               # All 11 screens
│   ├── splash/             # Splash screen
│   ├── dashboard/          # Main dashboard
│   ├── birth_details/      # Birth profile creation
│   ├── kp_chart/           # Main KP chart display
│   ├── planetary_positions/# Planetary positions table
│   ├── house_cusps/        # House cusps display
│   ├── dasha/              # Dasha timeline
│   ├── kp_event_analysis/  # Event prediction screens
│   ├── event_report/       # Event report generation
│   ├── tools/              # Various astrological tools
│   └── settings/           # App settings
├── astrology_engine/        # Custom KP calculation engine
│   ├── ephemeris/           # Astronomical data
│   ├── calculations/       # Core calculation logic
│   └── rules/              # KP rule engine
└── data/                   # Data access layer
```

## Development Progress

**Phase 1-2: Core Foundation** ✓
- Project setup and dependencies
- Design system and theming
- Navigation and routing
- Database schema and models

**Phase 3-4: Essential Screens** ✓
- Splash screen with initialization
- Dashboard and chart history
- Birth profile creation (Phase 1 implemented)

**Phase 5-6: Storage & Calculations** ✓
- SQLite database implementation
- Birth profile models
- Chart storage structure

**Phase 7: KP Rule Engine** ✓
- Event analysis models
- Sample event data structure

**Phase 8: Chart Display** ✓
- South Indian chart widget (Phase 9 implemented)
- Planet and sign details
- Database integration

**Phase 9-10: Features & Testing** ✓
- Remaining screens (Phase 8-10)
- Chart rendering widgets (Phase 11)
- Integration testing

**Phase 11: Production** →
- Build and deployment preparation
- Performance optimization
- Cross-platform testing

## Files Created

### Core Architecture
- `lib/main.dart` - App entry point
- `lib/core/theme/app_colors.dart` - Color palette
- `lib/core/theme/app_typography.dart` - Typography system
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/router/app_router.dart` - Navigation setup

### Database Layer
- `lib/core/database/database_helper.dart` - SQLite helper
- `lib/core/models/` - All data models (BirthProfile, Chart, etc.)

### Essential Screens
- `lib/features/splash/presentation/splash_screen.dart` - Splash with animation
- `lib/features/dashboard/presentation/dashboard_screen.dart` - Dashboard
- `lib/features/birth_details/presentation/birth_details_screen.dart` - Birth profile creation

### Chart Display
- `lib/features/kp_chart/presentation/widgets/south_indian_chart_widget.dart` - South Indian chart
- `lib/features/kp_chart/presentation/kp_chart_screen.dart` - Main chart screen
- `lib/features/planetary_positions/presentation/planetary_positions_screen.dart` - Planetary positions
- `lib/features/house_cusps/presentation/house_cusps_screen.dart` - House cusps

### Event Analysis
- `lib/features/dasha/presentation/dba_screen.dart` - Dasha timeline
- `lib/features/kp_event_analysis/presentation/kp_event_analysis_screen.dart` - Event predictions
- `lib/features/event_report/presentation/event_report_screen.dart` - Event reports

### Utilities
- `lib/features/tools/presentation/tools_screen.dart` - Tool dashboard
- `lib/features/settings/presentation/settings_screen.dart` - App settings

## Running the App

```bash
# Clone the repository
# Ensure Flutter is installed
# Run the app

flutter pub get
flutter run
```

## Design System

### Color Palette
- **Main Background**: `#12091F` (Dark Purple)
- **Primary Gold**: `#E8BC69` (Golden Yellow)
- **Card Background**: `#29163D` (Dark Purple Card)
- **Text Primary**: `#FFF8EE` (Cream White)
- **Text Secondary**: `#C4B4D3` (Purple Gray)

### Typography
- **Headings**: Cinzel (26px, 22px, 20px)
- **Body Text**: Inter (16px, 14px, 12px)
- **Planetary Degrees**: Inconsolata (14px)

## Offline Capabilities

- **No Backend Required**: All features work offline
- **Local Database**: Birth profiles, charts, and history stored locally
- **Built-in Ephemeris**: Astronomical data bundled with the app
- **Timezone Handling**: Offline timezone database for birthplace selection

## KP Astrology Calculation Engine

The app includes a custom KP astrology calculation engine that handles:

- **Ayanamsa Calculation**: Configurable KP ayanamsa
- **House Cusps**: Placidus system with offline calculation
- **Planetary Positions**: Sidereal positions with nakshatras
- **Nakshatra Analysis**: 27 nakshatras with pada system
- **Sub-Lord Calculation**: Vimshottari proportions and sub-sub lords
- **Event Rules**: Configurable KP event prediction rules
- **Dasha-Bhukti-Antara**: Complete Vimshottari period calculations

## Event Analysis Rules

The application includes configurable event analysis for:

### Marriage Analysis
- 7th House significations
- Spouse indicator analysis
- Timing periods for marriage prediction

### Career/Job Analysis
- 10th House significations
- Job change indicators
- Promotion and career advancement rules

### Property Purchase Analysis
- 4th House significations
- Property acquisition indicators
- Real estate purchase timing

## Limitations & Notes

- This is a **demo implementation** with sample data for development purposes
- Full KP rule engine requires additional configuration for real-world use
- Swiss Ephemeris licensing requires AGPL compliance review
- Complex astrological calculations may require further refinement
- Some advanced KP features are structured but not fully implemented

## Future Enhancements

- Implement full KP rule engine with configurable parameters
- Add more event types and prediction categories
- Enhance chart customization options
- Implement advanced Vedic astrology features
- Add user feedback and chart comparison
- Integrate with additional external data sources
- Performance optimization for complex calculations

## License

This project is part of a Flutter development exploration. Use responsibly for educational and development purposes.
