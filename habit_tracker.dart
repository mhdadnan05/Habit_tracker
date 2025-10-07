import 'package:flutter/material.dart';
import 'habit_model.dart';
import 'storage_service.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  List<Habit> _habits = [];
  final TextEditingController _habitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await StorageService.loadHabits();
    setState(() {
      _habits = habits;
    });
  }

  Future<void> _addHabit() async {
    final name = _habitController.text.trim();
    if (name.isEmpty) return;

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      completedDays: List.filled(7, false),
      createdAt: DateTime.now(),
    );

    await StorageService.addHabit(newHabit);
    _habitController.clear();
    await _loadHabits();
  }

  Future<void> _toggleHabitDay(int habitIndex, int dayIndex) async {
    final habit = _habits[habitIndex];
    final updatedDays = List<bool>.from(habit.completedDays);
    updatedDays[dayIndex] = !updatedDays[dayIndex];

    final updatedHabit = habit.copyWith(completedDays: updatedDays);
    await StorageService.updateHabit(updatedHabit);
    await _loadHabits();
  }

  Future<void> _deleteHabit(int index) async {
    final habit = _habits[index];
    await StorageService.deleteHabit(habit.id);
    await _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Habit Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add Habit Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _habitController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new habit...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addHabit(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addHabit,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Habits List
          Expanded(
            child: _habits.isEmpty
                ? const Center(
                    child: Text(
                      'No habits yet!\nAdd your first habit above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      return _buildHabitCard(habit, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, int habitIndex) {
    final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteHabit(habitIndex),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final isCompleted = habit.completedDays[dayIndex];
                return GestureDetector(
                  onTap: () => _toggleHabitDay(habitIndex, dayIndex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.blue : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dayNames[dayIndex],
                        style: TextStyle(
                          color: isCompleted ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}