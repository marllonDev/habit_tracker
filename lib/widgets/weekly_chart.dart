import 'dart:ui';
import 'package:flutter/material.dart';

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
    // Ensure we have exactly 7 days of data
    final safeData = weeklyData.length == 7 ? weeklyData : List.filled(7, 0);

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
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final i = 6 - index;
                    final date = now.subtract(Duration(days: i));
                    final amount = safeData[index];
                    
                    final dayName = DateFormat.E('pt_BR').format(date);
                    final shortDay = dayName.substring(0, 1).toUpperCase() + dayName.substring(1, 3);
                    
                    double ratio = amount / goal;
                    if (ratio > 1.0) ratio = 1.0;
                    if (amount > 0 && ratio < 0.2) ratio = 0.2; // Minimum height for text
                    
                    final verticalStr = amount > 0 ? amount.toString().split('').join('\n') : '';

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // Background Bar
                                  Container(
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  // Colored Filled Bar
                                  if (amount > 0)
                                    FractionallySizedBox(
                                      heightFactor: ratio,
                                      child: Container(
                                        width: 36,
                                        decoration: BoxDecoration(
                                          color: amount >= goal ? AppTheme.accent : AppTheme.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              verticalStr,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                height: 1.1,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              shortDay,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
