import 'task.dart';

class Project {
  final String name;
  final int tasksCount;
  final bool isAdmin;

  Project({
    required this.name,
    this.tasksCount = 0,
    required this.isAdmin,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['project_name'],
      tasksCount: json['tasks_count'],
      // isAdmin: json['is_admin'] ?? false,
      isAdmin: json['project_name'].length % 2 == 0, // FIX LATER NECESSARILY!!!!!!!! NEED TO TALK WITH BACKDEV
    );
  }
}
