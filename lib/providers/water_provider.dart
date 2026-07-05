import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/notification_service.dart';

class WaterState {
  final int current;
  final int goal;
  final int interval;

  WaterState({
    required this.current, 
    required this.goal,
    required this.interval,
  });

  WaterState copyWith({int? current, int? goal, int? interval}) {
    return WaterState(
      current: current ?? this.current,
      goal: goal ?? this.goal,
      interval: interval ?? this.interval,
    );
  }
}

final waterProvider = NotifierProvider<WaterNotifier, WaterState>(() {
  return WaterNotifier();
});

class WaterNotifier extends Notifier<WaterState> {
  Box? _box;

  @override
  WaterState build() {
    _init();
    return WaterState(current: 0, goal: 2000, interval: 60);
  }

  Future<void> _init() async {
    _box = await Hive.openBox('waterBox');
    final today = DateTime.now().toIso8601String().split('T').first;
    final current = _box?.get(today, defaultValue: 0) ?? 0;
    final goal = _box?.get('waterGoal', defaultValue: 2000) ?? 2000;
    final interval = _box?.get('waterInterval', defaultValue: 60) ?? 60;
    
    state = WaterState(current: current, goal: goal, interval: interval);
  }

  void addWater(int amount) {
    final today = DateTime.now().toIso8601String().split('T').first;
    final newValue = state.current + amount;
    
    if (state.current < state.goal && newValue >= state.goal) {
      NotificationService.showGoalAchievedNotification();
    }
    
    state = state.copyWith(current: newValue);
    _box?.put(today, newValue);
  }

  void resetWater() {
    final today = DateTime.now().toIso8601String().split('T').first;
    state = state.copyWith(current: 0);
    _box?.put(today, 0);
  }

  void setGoal(int newGoal) {
    state = state.copyWith(goal: newGoal);
    _box?.put('waterGoal', newGoal);
  }

  Future<void> setInterval(int newIntervalMinutes) async {
    state = state.copyWith(interval: newIntervalMinutes);
    await _box?.put('waterInterval', newIntervalMinutes);
    await NotificationService.scheduleWaterReminders(newIntervalMinutes);
  }
}
