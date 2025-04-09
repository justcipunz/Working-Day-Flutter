class Task {
  final String title;
  final String startDate;
  final String endDate;
  final String project;
  final String timeLeft;
  final String responsible;
  final String curator;
  final String description;
  final String status;
  final bool isUrgent;

  Task({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.project,
    required this.timeLeft,
    required this.responsible,
    required this.curator,
    required this.description,
    required this.isUrgent,
    required this.status,
  });
}
