// lib/views/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../main.dart';
import '../tasks/add_task_screen.dart';
import '../insights/insights_screen.dart';
import '../calendar/calendar_screen.dart';
import '../../core/utils/pdf_helper.dart';
import '../../core/utils/csv_helper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final progressPercentage = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 🚀 Animated Premium Progress Card
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _buildProgressCard(context, progressPercentage, completedTasks, totalTasks),
              ),
              const SizedBox(height: 32),
              Text(
                _isSearching ? "Search Results" : "Today's Missions",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: tasks.isEmpty
                    ? _buildEmptyState(context)
                    : _buildTaskList(tasks),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("New Task", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final rank = ref.watch(taskProvider.notifier).getUserRank();

    return AppBar(
      title: _isSearching
          ? Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search missions...",
            border: InputBorder.none,
            icon: Icon(Icons.search, size: 20, color: Colors.grey),
          ),
          onChanged: (value) => ref.read(taskProvider.notifier).searchTasks(value),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome back, Talha 👋", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(rank, style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => setState(() => _isSearching = true),
          ),
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                ref.read(taskProvider.notifier).loadTasks();
              });
            },
          ),
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded, color: Colors.orangeAccent),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded, color: Colors.blueAccent),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InsightsScreen())),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.download_rounded, color: Colors.green),
          onSelected: (value) async {
            final currentTasks = ref.read(taskProvider);
            if (currentTasks.isEmpty) return;
            if (value == 'pdf') await PdfHelper.generateAndSharePdf(currentTasks);
            else await CsvHelper.exportTasksToCsv(currentTasks);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'pdf', child: Text("Export as PDF")),
            const PopupMenuItem(value: 'csv', child: Text("Export as Excel (CSV)")),
          ],
        ),
        IconButton(
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          onPressed: () => ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark,
        ),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Dismissible(
            key: ValueKey(task.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => ref.read(taskProvider.notifier).deleteTask(task.id!),
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              shadowColor: Colors.black.withOpacity(0.1),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: _getPriorityColor(task.priority), width: 5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskScreen(existingTask: task)));
                  },
                  leading: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (!task.isCompleted) {
                        _showMoodPicker(context, task);
                      } else {
                        // 🚀 FIXED 1: Agar task pehle se complete hai, toh usay pending kar do aur mood null kar do
                        ref.read(taskProvider.notifier).toggleTaskCompletion(
                          task.copyWith(isCompleted: false, moodScore: null),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: task.isCompleted ? Colors.green : Colors.grey.shade400, width: 2),
                        color: task.isCompleted ? Colors.green : Colors.transparent,
                        boxShadow: task.isCompleted ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8)] : [],
                      ),
                      child: task.isCompleted ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                    ),
                  ),
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null, // 🚀 Line through here
                      decorationColor: Colors.grey,
                    ),
                    child: Text(task.title),
                  ),
                  subtitle: Text(task.description ?? "", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  trailing: task.moodScore != null
                      ? Text(_getMoodEmoji(task.moodScore!), style: const TextStyle(fontSize: 20))
                      : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2: return Colors.redAccent;
      case 1: return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }

  void _showMoodPicker(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              const Text("Mission Accomplished! 🚀", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("How do you feel right now?", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final score = index + 1;
                  return InkWell(
                    onTap: () {
                      // 🚀 FIXED 2: Jab mood select ho, tab 'isCompleted' ko lazmi 'true' bhejo!
                      ref.read(taskProvider.notifier).toggleTaskCompletion(
                        task.copyWith(moodScore: score, isCompleted: true),
                      );
                      Navigator.pop(context);
                      HapticFeedback.heavyImpact();
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Transform.scale(
                      scale: 1.2,
                      child: Text(_getMoodEmoji(score), style: const TextStyle(fontSize: 36)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getMoodEmoji(int score) {
    const emojis = ["😫", "😐", "🙂", "😊", "🤩"];
    return emojis[score - 1];
  }

  Widget _buildProgressCard(BuildContext context, double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daily Progress", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text("$completed / $total Tasks", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 8.0,
            percent: progress,
            center: Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            progressColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
            animation: true,
            animationDuration: 1000,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network('https://lottie.host/7f72eb50-6a98-4b77-b844-3d9db2f518e3/qJ9zB0CqU9.json', height: 180),
            const SizedBox(height: 16),
            const Text("Your schedule is clear!", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}