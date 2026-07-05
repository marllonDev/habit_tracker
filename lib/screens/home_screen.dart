import 'dart:io' show Platform;
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../providers/water_provider.dart';
import '../widgets/weekly_chart.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WaterState>(waterProvider, (previous, next) {
      if (previous != null) {
        final wasBelowGoal = previous.current < previous.goal;
        final isNowAtOrAboveGoal = next.current >= next.goal;

        if (wasBelowGoal && isNowAtOrAboveGoal) {
          _confettiController.play();
        }
      }
    });

    final waterState = ref.watch(waterProvider);
    final waterAmount = waterState.current;
    final waterGoal = waterState.goal;
    final waterInterval = waterState.interval;
    
    final now = DateTime.now();
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final weekdays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    final todayDate = "${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}";

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF020617), // Slate 950
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF082F49), // Deep Sky Blue dark
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Text(
                      todayDate,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Meu Progresso',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notification Interval Card
                    _buildNotificationCard(context, ref, waterInterval),
                    const SizedBox(height: 16),

                    // Daily Goal Glass Card
                    _buildGoalCard(context, ref, waterGoal, waterAmount),
                    const SizedBox(height: 24),

                    // Weekly Chart (Replaces Water Bottle)
                    const Expanded(
                      child: WeeklyChart(),
                    ),
                    const SizedBox(height: 24),

                    // Add Water Actions
                    Center(child: _buildAddWaterActions(ref)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.blue, Colors.lightBlueAccent, Colors.white],
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, int goal, int current) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meta Diária',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat('#,###', 'pt_BR').format(goal)} ml',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.bottleWater,
                      color: AppTheme.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${((current / goal) * 100).clamp(0, 100).toStringAsFixed(0)}% Concluído',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  icon: Platform.isIOS ? CupertinoIcons.pencil : Icons.edit,
                  label: 'Editar Meta',
                  onPressed: () => _showSetGoalDialog(context, ref, goal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassButton(
                  icon: Platform.isIOS ? CupertinoIcons.arrow_counterclockwise : Icons.refresh,
                  label: 'Zerar Água',
                  onPressed: () => ref.read(waterProvider.notifier).resetWater(),
                  isDestructive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, int currentInterval) {
    String intervalText;
    if (currentInterval < 60) {
      intervalText = 'A cada $currentInterval minutos';
    } else {
      final hours = currentInterval ~/ 60;
      intervalText = hours == 1 ? 'A cada 1 hora' : 'A cada $hours horas';
    }

    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Intervalo de Notificação',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  intervalText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
            onPressed: () => _showSetIntervalDialog(context, ref, currentInterval),
          ),
        ],
      ),
    );
  }

  Widget _buildAddWaterActions(WidgetRef ref) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        _WaterActionButton(
          amount: 250,
          onPressed: () => ref.read(waterProvider.notifier).addWater(250),
        ),
        _WaterActionButton(
          amount: 500,
          onPressed: () => ref.read(waterProvider.notifier).addWater(500),
        ),
      ],
    );
  }

  void _showSetGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(text: NumberFormat('#,###', 'pt_BR').format(currentGoal));
    showDialog(
      context: context,
      builder: (context) => Platform.isIOS
          ? CupertinoAlertDialog(
              title: const Text('Meta Diária (ml)'),
              content: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: CupertinoTextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    final newGoal = int.tryParse(controller.text.replaceAll('.', '').trim());
                    if (newGoal != null && newGoal > 0) {
                      ref.read(waterProvider.notifier).setGoal(newGoal);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            )
          : AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Meta Diária (ml)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ex: 2500',
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final newGoal = int.tryParse(controller.text.replaceAll('.', '').trim());
                    if (newGoal != null && newGoal > 0) {
                      ref.read(waterProvider.notifier).setGoal(newGoal);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
    );
  }

  void _showSetIntervalDialog(BuildContext context, WidgetRef ref, int currentInterval) {
    final intervals = [3, 15, 30, 60, 90, 120, 180];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Frequência de Avisos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: intervals.length,
            itemBuilder: (context, index) {
              final val = intervals[index];
              String label;
              if (val < 60) {
                label = '$val minutos';
              } else {
                label = val == 60 ? '1 hora' : '${val ~/ 60} horas';
              }
              
              final isSelected = val == currentInterval;
              
              return ListTile(
                title: Text(label, style: TextStyle(color: isSelected ? AppTheme.primary : Colors.white)),
                trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
                onTap: () {
                  ref.read(waterProvider.notifier).setInterval(val);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterActionButton extends StatelessWidget {
  final int amount;
  final VoidCallback onPressed;

  const _WaterActionButton({required this.amount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(FontAwesomeIcons.bottleWater, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            '+$amount ml',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
