// lib/views/tasks/add_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final Task? existingTask;
  const AddTaskScreen({super.key, this.existingTask});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedCategoryId;
  late int _selectedPriority;
  late String _repeatRule;

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Study', 'color': const Color(0xFF6C63FF)},
    {'id': 2, 'name': 'Health', 'color': const Color(0xFF4CAF50)},
    {'id': 3, 'name': 'Work', 'color': const Color(0xFFFF9800)},
    {'id': 4, 'name': 'Personal', 'color': const Color(0xFFE91E63)},
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');

    _selectedDate = task?.dueDate ?? DateTime.now();
    _selectedTime = task != null ? TimeOfDay.fromDateTime(task.dueDate) : TimeOfDay.now();
    _selectedCategoryId = task?.categoryId ?? 1;
    _selectedPriority = task?.priority ?? 0;
    _repeatRule = task?.repeatRule ?? 'none';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveOrUpdateTask() {
    if (_formKey.currentState!.validate()) {
      // 🚀 Premium Touch: Success Vibration
      HapticFeedback.mediumImpact();

      final finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final isEditing = widget.existingTask != null;

      final taskData = Task(
        id: isEditing ? widget.existingTask!.id : null,
        categoryId: _selectedCategoryId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: finalDateTime,
        priority: _selectedPriority,
        repeatRule: _repeatRule,
        isCompleted: isEditing ? widget.existingTask!.isCompleted : false,
        moodScore: isEditing ? widget.existingTask!.moodScore : null,
      );

      if (isEditing) {
        ref.read(taskProvider.notifier).toggleTaskCompletion(taskData);
      } else {
        ref.read(taskProvider.notifier).addTask(taskData);
      }

      // 💬 Premium Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: isEditing ? Colors.blueAccent : Colors.green.shade600,
          content: Row(
            children: [
              Icon(isEditing ? Icons.edit_rounded : Icons.rocket_launch_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(isEditing ? 'Mission Updated!' : 'Mission Launched! 🚀'),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      // ❌ Error Vibration
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Mission' : 'New Mission',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("What's the mission?"),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Final Year Project Submission',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Mission name is required' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel("Briefing (Optional)"),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Add some details about this task...',
                  ),
                ),
                const SizedBox(height: 32),

                _buildLabel("Sector / Category"),
                const SizedBox(height: 12),
                _buildCategoryList(),
                const SizedBox(height: 32),

                _buildLabel("Deadline"),
                const SizedBox(height: 12),
                _buildDateTimePicker(context),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(child: _buildPriorityDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRepeatDropdown()),
                  ],
                ),
                const SizedBox(height: 48),

                _buildLaunchButton(isEditing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryId == cat['id'];
          return ChoiceChip(
            label: Text(cat['name']),
            selected: isSelected,
            onSelected: (val) {
              if(val) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategoryId = cat['id']);
              }
            },
            selectedColor: cat['color'],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPickerTile(
            icon: Icons.calendar_month_rounded,
            label: "Date",
            value: DateFormat('MMM dd, yyyy').format(_selectedDate),
            onTap: () async {
              final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030)
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPickerTile(
            icon: Icons.access_time_rounded,
            label: "Time",
            value: _selectedTime.format(context),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _selectedTime);
              if (picked != null) setState(() => _selectedTime = picked);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPickerTile({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedPriority,
      decoration: const InputDecoration(labelText: 'Priority'),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Low')),
        DropdownMenuItem(value: 1, child: Text('Medium')),
        DropdownMenuItem(value: 2, child: Text('High', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
      ],
      onChanged: (val) => setState(() => _selectedPriority = val!),
    );
  }

  Widget _buildRepeatDropdown() {
    return DropdownButtonFormField<String>(
      value: _repeatRule,
      decoration: const InputDecoration(labelText: 'Repeat'),
      items: const [
        DropdownMenuItem(value: 'none', child: Text('Once')),
        DropdownMenuItem(value: 'daily', child: Text('Daily')),
        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
      ],
      onChanged: (val) => setState(() => _repeatRule = val!),
    );
  }

  Widget _buildLaunchButton(bool isEditing) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
      ),
      child: ElevatedButton.icon(
        onPressed: _saveOrUpdateTask,
        icon: Icon(isEditing ? Icons.save_rounded : Icons.rocket_launch_rounded),
        label: Text(isEditing ? 'Update Mission' : 'Launch Mission',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}