class Task {
  final String taskName;
  final String category;
  final String feedback;
  final double percentage;

  Task({
    required this.taskName,
    required this.category,
    required this.feedback,
    required this.percentage,
  });

  factory Task.fromFirestore(Map<String, dynamic> data) {
    return Task(
      taskName: data['task_name'] ?? 'Unnamed Task',
      category: data['category'] ?? 'Uncategorized',
      feedback: data['feedback'] ?? 'No feedback',
      percentage: (data['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
