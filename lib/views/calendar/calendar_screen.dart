// lib/views/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../tasks/add_task_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // 🚀 ELITE FIX: Screen khulte hi automatically aaj ki date select ho jaye
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mission Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 📅 PREMIUM CALENDAR UI
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              startingDayOfWeek: StartingDayOfWeek.monday,

              // Custom Header Styling
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // Custom Days Styling
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 10)],
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),

              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },

              // Marker logic: Show dots for tasks
              eventLoader: (day) {
                return allTasks.where((task) => isSameDay(task.dueDate, day)).toList();
              },
            ),
          ),

          const SizedBox(height: 16),

          // 🚀 DATE HEADER FOR LIST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedDay != null && isSameDay(_selectedDay, DateTime.now())
                    ? "Today's Schedule"
                    : DateFormat('EEEE, MMM d').format(_selectedDay ?? DateTime.now()),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 📝 ANIMATED TASK LIST
          Expanded(
            child: _buildDayTasks(allTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTasks(List<Task> allTasks) {
    final dayTasks = allTasks.where((task) => isSameDay(task.dueDate, _selectedDay)).toList();

    if (dayTasks.isEmpty) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) => Opacity(opacity: value, child: child),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network('https://lottie.host/7f72eb50-6a98-4b77-b844-3d9db2f518e3/qJ9zB0CqU9.json', height: 140),
              const SizedBox(height: 16),
              const Text("Day is clear! Take a rest.", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: dayTasks.length,
      itemBuilder: (context, index) {
        final task = dayTasks[index];

        // 🚀 Smooth Staggered Animation
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shadowColor: Colors.black.withOpacity(0.05),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: _getPriorityColor(task.priority), width: 5)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskScreen(existingTask: task),
                    ),
                  );
                },
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat('hh:mm a').format(task.dueDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                trailing: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  ),
                  child: Icon(
                    task.isCompleted ? Icons.check_rounded : Icons.hourglass_empty_rounded,
                    color: task.isCompleted ? Colors.green : Colors.orange,
                    size: 16,
                  ),
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
}