import 'task.dart';

class Project {
  final String name;
  final bool isAdmin;
  int taskCount;
  late List<Task> tasks;

  Project({
    required this.name,
    required this.isAdmin,
    this.taskCount = 0,
    this.tasks = const [],
  });

  void addTask(Task task) {
    tasks.add(task);
  }

  void setTasks(List<Task> tasks) {
    this.tasks = tasks; 
  }
}
