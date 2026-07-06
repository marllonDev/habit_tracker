import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class WeeklyChart extends StatelessWidget {
  final List<int> weeklyData;
  final int goal;

  const WeeklyChart({
    super.key,
    required this.weeklyData,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    List<BarChartGroupData> barGroups = [];
    List<String> days = [];
    
    // Ensure we have exactly 7 days of data
    final safeData = weeklyData.length == 7 ? weeklyData : List.filled(7, 0);

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final amount = safeData[6 - i];
      
      final dayName = DateFormat.E('pt_BR').format(date);
      days.add(dayName.substring(0, 1).toUpperCase() + dayName.substring(1, 3));
      
      // Calculate display Y ensuring bars are visible even for small/zero amounts
      double displayY = amount.toDouble();
      if (amount == 0) {
        displayY = goal * 0.02; // Small 2% sliver to ensure fl_chart renders the background rod and allows touch
      } else if (amount < goal * 0.15) {
        displayY = goal * 0.15; // Make small values (e.g. 250 out of 2000) distinctly visible at 15% height
      }
      
      final backgroundToY = goal.toDouble() > amount.toDouble() ? goal.toDouble() : amount.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: displayY,
              color: amount >= goal ? AppTheme.accent : AppTheme.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: backgroundToY,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Últimos 7 Dias',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    alignment: BarChartAlignment.spaceAround,
                    maxY: goal.toDouble() * 1.5,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          // Retrieve the actual amount from the array to prevent displaying the minimum visibility hacks
                          final actualAmount = safeData[group.x.toInt()];
                          return BarTooltipItem(
                            '$actualAmount ml\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < 0 || value.toInt() >= days.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
