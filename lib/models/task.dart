// lib/models/task.dart

class Task {
  final int? id;
  final int categoryId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final int priority; // 0: Low, 1: Medium, 2: High
  final bool isCompleted;
  final String? repeatRule; // 'none', 'daily', 'weekly'
  final int? notificationId;

  // 🚀 NEW FIELDS FOR MOOD TRACKER (FYP Connection)
  final int? moodScore; // 1: Sad, 5: Awesome
  final String? moodNote; // Why the user felt that way

  Task({
    this.id,
    required this.categoryId,
    required this.title,
    this.description,
    required this.dueDate,
    this.priority = 0,
    this.isCompleted = false,
    this.repeatRule = 'none',
    this.notificationId,
    this.moodScore,
    this.moodNote,
  });

  // 🚀 ELITE UPGRADE: Smart Getters for UI Logic
  // Ye properties app ko smart banati hain. Hum directly check kar sakte hain ke task late toh nahi hua!
  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
  bool get hasHighPriority => priority == 2;

  // 🛠️ ELITE UPGRADE: Fully Powered CopyWith Method
  // Ab tum Edit Form se koi bhi cheez update karo, ye perfect naya instance banayega!
  Task copyWith({
    int? id,
    int? categoryId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? isCompleted,
    String? repeatRule,
    int? notificationId,
    int? moodScore,
    String? moodNote,
  }) {
    return Task(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatRule: repeatRule ?? this.repeatRule,
      notificationId: notificationId ?? this.notificationId,
      moodScore: moodScore ?? this.moodScore,
      moodNote: moodNote ?? this.moodNote,
    );
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'is_completed': isCompleted ? 1 : 0,
      'repeat_rule': repeatRule,
      'notification_id': notificationId,
      'mood_score': moodScore,
      'mood_note': moodNote,
    };
  }

  // Convert from SQLite Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['due_date'] as String),
      priority: map['priority'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      repeatRule: map['repeat_rule'] as String?,
      notificationId: map['notification_id'] as int?,
      moodScore: map['mood_score'] as int?,
      moodNote: map['mood_note'] as String?,
    );
  }
}