class Task {
  final String id;
  final String title;
  final String projectName; // fix later!!!!
  final String description;
  final String creator;
  final String assignee;
  final String status; // "Open", "InProgress", "Review", "Done"
  final List<String> mediaLinks;
  final String startDate;
  final String endDate;
  final bool isUrgent;

  String get project => projectName; 
  int get timeLeft => _calculateTimeLeft();
  String get curator => creator; 
  String get responsible => assignee;

  int _calculateTimeLeft() {
    final end = DateTime.parse(endDate);
    final now = DateTime.now();
    final difference = end.difference(now);
    return difference.inHours;
  }

  Task({
    required this.id,
    required this.title,
    required this.projectName,
    required this.description,
    required this.creator,
    required this.assignee,
    required this.status,
    required this.mediaLinks,
    required this.startDate,
    required this.endDate,
    required this.isUrgent,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] as String?)?.isNotEmpty == true ? json['id']! : 'no-id',
      title: (json['title'] as String?)?.isNotEmpty == true
          ? json['title']!
          : 'Без названия',
      projectName: (json['project_name'] as String?)?.isNotEmpty == true
          ? json['project_name']!
          : 'Без проекта',
      description: (json['description'] as String?) ?? '',
      creator: (json['creator'] as String?) ?? 'Неизвестный',
      assignee: (json['assignee'] as String?) ?? '',
      status: _mapStatus(json['status'] as String?),
      mediaLinks: (json['media_links'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startDate: (json['start_date'] as String?) ?? 'Не указано',
      endDate: (json['end_date'] as String?) ?? 'Не указано',
      isUrgent: json['is_urgent'] as bool? ?? false,
    );
  }

  static String _mapStatus(String? apiStatus) {
    switch (apiStatus) {
      case 'Open':
        return 'Новая';
      case 'InProgress':
        return 'В работе';
      case 'Review':
        return 'На рассмотрении';
      case 'Done':
        return 'Выполнено';
      default:
        return 'Новая';
    }
  }
}
