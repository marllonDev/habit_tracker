import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaterBottle extends StatelessWidget {
  final int currentAmount;
  final int goal;

  const WaterBottle({
    super.key,
    required this.currentAmount,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    double fillPercentage = currentAmount / goal;
    if (fillPercentage > 1.0) fillPercentage = 1.0;

    return Container(
      width: 140,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(50),
          top: Radius.circular(50),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            height: 280 * fillPercentage,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: const Radius.circular(46),
                top: Radius.circular(fillPercentage >= 0.95 ? 46 : 0),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.accent,
                  AppTheme.primary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(46),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.1),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
