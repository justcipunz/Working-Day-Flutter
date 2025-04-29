import 'package:flutter/material.dart';
import '../data/project.dart';
import '../data/task.dart';
import '../domain/tracker_service.dart';
import 'section_title.dart';
import 'task_card.dart';
import 'task_page.dart';

class ProjectInfo extends StatefulWidget {
  final Project project;
  final VoidCallback onBack;

  const ProjectInfo({
    super.key,
    required this.project,
    required this.onBack,
  });

  @override
  State<ProjectInfo> createState() => _ProjectInfoState();
}

class _ProjectInfoState extends State<ProjectInfo> {
  int _currentSection = 0;
  late Future<List<Task>> _tasksFuture;

  final List<Map<String, dynamic>> _kanbanColumns = const [
    {'status': 'Новая', 'color': Color(0xFF7A91B8)},
    {'status': 'В работе', 'color': Color(0xFFDFB8B9)},
    {'status': 'На рассмотрении', 'color': Color(0xFFABABAB)},
    {'status': 'Выполнено', 'color': Color(0xFF164F94)},
  ];

  @override
  void initState() {
    super.initState();
    _tasksFuture = _loadTasks();
  }

  Future<List<Task>> _loadTasks() async {
    try {
      return await TrackerService.getTasksByProject(widget.project.name);
    } catch (e) {
      print('Ошибка загрузки задач: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
                Expanded(
                  child: SectionTitle.large(text: widget.project.name),
                ),
              ],
            ),
          ),
          _buildPhaseNavigation(),
          if (_currentSection == 0 && widget.project.isAdmin)
            _buildAddTaskButton(),
          _currentSection == 0
              ? _buildKanbanBoard()
              : _currentSection == 1
                  ? _buildProjectProgress()
                  : _buildProjectParticipants(),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF164F94),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskPage(
                isAdmin: true,
              ),
            ),
          );
        },
        child: const Text(
          "Добавить задачу",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton("Канбан-доска", 0),
            const SizedBox(width: 10),
            _buildNavButton("Прогресс", 1),
            const SizedBox(width: 10),
            _buildNavButton("Участники", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String title, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: _currentSection == index
                ? const Color(0xFF164F94)
                : const Color(0xFFEBECF0)),
        onPressed: () => setState(() => _currentSection = index),
        child: Text(title,
            style: TextStyle(
                color: _currentSection == index ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildKanbanBoard() {
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            heightFactor: 10,
            child: CircularProgressIndicator(color: Color(0xFF164F94)),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error!);
        }

        final allTasks = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.hasBoundedHeight
                  ? constraints.maxHeight * 0.8
                  : MediaQuery.of(context).size.height * 0.7;

              return SizedBox(
                height: maxHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _kanbanColumns.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final column = _kanbanColumns[index];
                    final tasks = allTasks
                        .where((t) => t.status == column['status'])
                        .toList();

                    return _KanbanColumn(
                      status: column['status'] as String,
                      tasks: tasks,
                      color: column['color'] as Color,
                      maxHeight: constraints.maxHeight,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            'Ошибка загрузки задач: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _tasksFuture = _loadTasks()),
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }

  int _getCompletedTasksCount(List<Task> tasks) {
    return tasks.where((task) => task.status == 'Выполнено').length;
  }

  Set<String> _getParticipants(List<Task> tasks) {
    return tasks
        .map((task) => task.assignee)
        .where((assignee) => assignee.isNotEmpty)
        .toSet();
  }

  (String, String) _getProjectDeadlines(List<Task> tasks) {
    if (tasks.isEmpty) return ('Нет данных', 'Нет данных');

    DateTime? earliestStart;
    DateTime? latestEnd;

    for (final task in tasks) {
      final start = DateTime.tryParse(task.startDate);
      final end = DateTime.tryParse(task.endDate);

      if (start != null) {
        earliestStart = earliestStart == null
            ? start
            : (start.isBefore(earliestStart) ? start : earliestStart);
      }

      if (end != null) {
        latestEnd = latestEnd == null
            ? end
            : (end.isAfter(latestEnd) ? end : latestEnd);
      }
    }

    final startStr = earliestStart != null
        ? "${earliestStart.day.toString().padLeft(2, '0')}."
            "${earliestStart.month.toString().padLeft(2, '0')}."
            "${earliestStart.year}"
        : 'Нет данных';

    final endStr = latestEnd != null
        ? "${latestEnd.day.toString().padLeft(2, '0')}."
            "${latestEnd.month.toString().padLeft(2, '0')}."
            "${latestEnd.year}"
        : 'Нет данных';

    return (startStr, endStr);
  }

  Widget _buildProjectProgress() {
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final tasks = snapshot.data!;
        final completedCount = _getCompletedTasksCount(tasks);
        final participantsCount = _getParticipants(tasks).length;
        final (startDate, endDate) = _getProjectDeadlines(tasks);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Прогресс по проекту",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF164F94),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProgressItem(
                      "Выполнено задач", "$completedCount/${tasks.length}"),
                  const Divider(height: 30),
                  _buildProgressItem(
                      "Участников проекта", participantsCount.toString()),
                  const Divider(height: 30),
                  _buildProgressItem(
                    "Сроки выполнения",
                    "$startDate - $endDate",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFABABAB),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF164F94),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectParticipants() {
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final participants = _getParticipants(snapshot.data!).toList();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Поиск участников...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildParticipantList(participants),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantList(List<String> participants) {
    return Column(
      children: participants
          .map((participant) => _buildParticipantTile(participant))
          .toList(),
    );
  }

  Widget _buildParticipantTile(String username) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF164F94),
        child: Text(
          username.isNotEmpty ? username[0] : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        username,
        style: const TextStyle(color: Color(0xFF164F94)),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String status;
  final List<Task> tasks;
  final Color color;
  final double maxHeight;

  const _KanbanColumn({
    required this.status,
    required this.tasks,
    required this.maxHeight,
    this.color = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.85,
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: maxHeight * 0.75,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    status,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => TaskCard(
                        task: tasks[index],
                        isUrgent: tasks[index].isUrgent,
                        showProject: false,
                        showResponsible: true,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "Нет задач",
        style: TextStyle(
          color: color.withAlpha(150),
          fontSize: 14,
        ),
      ),
    );
  }
}
