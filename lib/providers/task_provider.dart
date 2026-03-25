// lib/providers/task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../models/task.dart';
import '../core/utils/notification_helper.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    loadTasks();
  }

  final dbHelper = DatabaseHelper.instance;

  // 1. READ: Fetch all tasks
  Future<void> loadTasks() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'due_date ASC');
    state = maps.map((map) => Task.fromMap(map)).toList();
  }

  // 🔍 Search Logic
  Future<void> searchTasks(String query) async {
    if (query.isEmpty) {
      await loadTasks();
      return;
    }
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'due_date ASC',
    );
    state = maps.map((map) => Task.fromMap(map)).toList();
  }

  // 🚀 STATS: For Insights & Badges
  Map<String, int> getCategoryStats() {
    Map<String, int> stats = {"Study": 0, "Health": 0, "Work": 0, "Personal": 0};
    for (var task in state) {
      if (task.categoryId == 1) stats["Study"] = stats["Study"]! + 1;
      else if (task.categoryId == 2) stats["Health"] = stats["Health"]! + 1;
      else if (task.categoryId == 3) stats["Work"] = stats["Work"]! + 1;
      else stats["Personal"] = stats["Personal"]! + 1;
    }
    return stats;
  }

  double getCompletionRate() {
    if (state.isEmpty) return 0.0;
    final completed = state.where((t) => t.isCompleted).length;
    return (completed / state.length) * 100;
  }

  // 🎖️ Gamification Rank Logic
  String getUserRank() {
    final completedCount = state.where((t) => t.isCompleted).length;
    if (completedCount >= 20) return "Grandmaster 🏆";
    if (completedCount >= 10) return "Elite Commander 🎖️";
    if (completedCount >= 5) return "Rising Star ⭐";
    if (completedCount >= 1) return "Recruit 🔰";
    return "Newbie 🌱";
  }

  // 2. CREATE: Add Task + Notification
  Future<void> addTask(Task task) async {
    final db = await dbHelper.database;
    final int newTaskId = await db.insert('tasks', task.toMap());

    await NotificationHelper.scheduleNotification(
      id: newTaskId,
      title: 'Mission Reminder: ${task.title}',
      body: 'It is time to execute your mission. Let\'s go!',
      scheduledTime: task.dueDate,
    );

    await loadTasks();
  }

  // 3. UPDATE: Universal Update (Handles Edit Form, Checkbox Toggle, & Mood)
  Future<void> toggleTaskCompletion(Task task) async {
    final db = await dbHelper.database;

    // Database update
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    // 🚀 SMART NOTIFICATION LOGIC:
    // Pehle purana alarm cancel karo. Phir agar task complete nahi hai, toh naya alarm set karo.
    // Ye edit kiye gaye date/time ko bhi perfectly handle karega!
    await NotificationHelper.cancelNotification(task.id!);
    if (!task.isCompleted) {
      await NotificationHelper.scheduleNotification(
        id: task.id!,
        title: 'Mission Reminder: ${task.title}',
        body: 'It is time to execute your mission. Let\'s go!',
        scheduledTime: task.dueDate,
      );
    }

    await loadTasks();
  }

  // 4. DELETE: Delete + Cancel Notification
  Future<void> deleteTask(int id) async {
    final db = await dbHelper.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    await NotificationHelper.cancelNotification(id);
    await loadTasks();
  }
}