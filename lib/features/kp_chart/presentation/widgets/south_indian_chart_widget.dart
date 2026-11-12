import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/planetary_position.dart';

class SouthIndianChartWidget extends StatelessWidget {
  final List<PlanetaryPosition> planets;
  final String lagnaSign;
  final bool showDegrees;
  final bool showHouseNumbers;
  final List<int> highlightedHouses;
  final Function(PlanetaryPosition)? onPlanetTap;
  final Function(String)? onSignTap;

  const SouthIndianChartWidget({
    super.key,
    required this.planets,
    required this.lagnaSign,
    this.showDegrees = true,
    this.showHouseNumbers = true,
    this.highlightedHouses = const [],
    this.onPlanetTap,
    this.onSignTap,
  });

  // South Indian fixed sign arrangement:
  // Row 0: Pisces (11), Aries (0), Taurus (1), Gemini (2)
  // Row 1: Aquarius (10), CENTER, CENTER, Cancer (3)
  // Row 2: Capricorn (9), CENTER, CENTER, Leo (4)
  // Row 3: Sagittarius (8), Scorpio (7), Libra (6), Virgo (5)

  static const List<String> signsInLayout = [
    'Pisces', 'Aries', 'Taurus', 'Gemini',
    'Aquarius', 'CENTER', 'CENTER', 'Cancer',
    'Capricorn', 'CENTER', 'CENTER', 'Leo',
    'Sagittarius', 'Scorpio', 'Libra', 'Virgo',
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGold, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              // Row 0
              Expanded(
                child: Row(
                  children: [
                    _buildSignBox(0, 'Pisces'),
                    _buildSignBox(1, 'Aries'),
                    _buildSignBox(2, 'Taurus'),
                    _buildSignBox(3, 'Gemini'),
                  ],
                ),
              ),
              // Row 1
              Expanded(
                child: Row(
                  children: [
                    _buildSignBox(4, 'Aquarius'),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: AppColors.secondaryBackground,
                        child: _buildCenterChartContent(),
                      ),
                    ),
                    _buildSignBox(7, 'Cancer'),
                  ],
                ),
              ),
              // Row 2
              Expanded(
                child: Row(
                  children: [
                    _buildSignBox(8, 'Capricorn'),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: AppColors.secondaryBackground,
                      ),
                    ),
                    _buildSignBox(11, 'Leo'),
                  ],
                ),
              ),
              // Row 3
              Expanded(
                child: Row(
                  children: [
                    _buildSignBox(12, 'Sagittarius'),
                    _buildSignBox(13, 'Scorpio'),
                    _buildSignBox(14, 'Libra'),
                    _buildSignBox(15, 'Virgo'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignBox(int index, String signName) {
    final isLagna = signName.toLowerCase() == lagnaSign.toLowerCase();

    // Get planets in this sign
    final planetsInSign = planets.where((p) => p.sign.toLowerCase() == signName.toLowerCase()).toList();

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onSignTap != null) {
            onSignTap!(signName);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isLagna
                ? AppColors.primaryGold.withOpacity(0.15)
                : AppColors.cardBackground,
            border: Border.all(
              color: isLagna ? AppColors.primaryGold : AppColors.borders,
              width: isLagna ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sign Header (Name & Lagna tag)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    signName.substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isLagna ? AppColors.primaryGold : AppColors.secondaryText,
                    ),
                  ),
                  if (isLagna)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'Asc',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainBackground,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              // Planets list
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: planetsInSign.map((planet) {
                  return GestureDetector(
                    onTap: () {
                      if (onPlanetTap != null) {
                        onPlanetTap!(planet);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: planet.getPlanetColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: planet.getPlanetColor(),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${planet.planetName.substring(0, 2)}${planet.retrograde ? ' R' : ''}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: planet.getPlanetColor(),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterChartContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'KP RĀŚI CHART',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 12,
              color: AppColors.primaryGold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'South Indian Style',
            style: AppTypography.labelSmall.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
