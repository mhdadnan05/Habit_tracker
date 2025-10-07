import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_model.dart';

class StorageService {
  static const String _habitsKey = 'habits';

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList(_habitsKey) ?? [];
    
    return habitsJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Habit.fromJson(map);
    }).toList();
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = habits.map((habit) => jsonEncode(habit.toJson())).toList();
    await prefs.setStringList(_habitsKey, habitsJson);
  }

  static Future<void> addHabit(Habit habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  static Future<void> updateHabit(Habit updatedHabit) async {
    final habits = await loadHabits();
    final index = habits.indexWhere((habit) => habit.id == updatedHabit.id);
    if (index != -1) {
      habits[index] = updatedHabit;
      await saveHabits(habits);
    }
  }

  static Future<void> deleteHabit(String habitId) async {
    final habits = await loadHabits();
    habits.removeWhere((habit) => habit.id == habitId);
    await saveHabits(habits);
  }
}