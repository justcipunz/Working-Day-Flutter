class Task {
  final String id;
  final String title;
  final String projectName;
  final String description;
  final String creator;
  final String assignee;
  String status; // "Open", "InProgress", "Review", "Done"
  String startDate;
  String endDate;
  final bool isUrgent;
  final List<String>? mediaLinks;

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
    required this.startDate,
    required this.endDate,
    required this.isUrgent,
    this.mediaLinks,
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
      status: _convertStatusFromApi(json['status'] as String?),
      mediaLinks: (json['media_links'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startDate: (json['start_date'] as String?) ?? 'Не указано',
      endDate: (json['end_date'] as String?) ?? 'Не указано',
      isUrgent: json['is_urgent'] as bool? ?? false,
    );
  }

  static String _convertStatusFromApi(String? apiStatus) {
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

  factory Task.empty() => Task(
        id: '',
        title: '',
        projectName: '',
        description: '',
        creator: '',
        assignee: '',
        status: 'Новая',
        startDate: '',
        endDate: '',
        isUrgent: false,
        mediaLinks: [],
      );

  Task copyWith({
    String? id,
    String? title,
    String? projectName,
    String? description,
    String? creator,
    String? assignee,
    String? status,
    String? startDate,
    String? endDate,
    bool? isUrgent,
    List<String>? mediaLinks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      creator: creator ?? this.creator,
      assignee: assignee ?? this.assignee,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isUrgent: isUrgent ?? this.isUrgent,
      mediaLinks: mediaLinks ?? this.mediaLinks,
    );
  }

  @override
  String toString() {
    return '''
Task {
  id: $id,
  title: $title,
  project: $projectName,
  status: $status,
  creator: $creator,
  assignee: $assignee,
  startDate: $startDate,
  endDate: $endDate,
  description: ${description.length > 20 ? '${description.substring(0, 17)}...' : description},
}''';
  }
}
