import 'task.dart';

class Project {
  final String name;
  final int tasksCount;
  final bool isAdmin;
  List<Task> tasks;

  Project({
    required this.name,
    required this.tasksCount,
    required this.isAdmin,
    this.tasks = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['project_name'],
      tasksCount: json['tasks_count'],
      isAdmin: json['is_admin'] ?? false,
      tasks: List<Task>.from(json['tasks'].map((t) => Task.fromJson(t))),
    );
  }
}
