import 'package:flutter/material.dart';
import 'package:test/user/domain/user_preferences.dart';
import '../domain/tracker_service.dart';
import 'navigation_bar.dart';
import 'section_title.dart';
import '../data/task.dart';
import 'task_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _loadTasks();
  }

  Future<List<Task>> _loadTasks() async {
    try {
      // final me = await UserPreferences.fetchProfileInfo();
      // print(me.id);
      // return await TrackerService.getAssignedTasks(me.id!);
      return await TrackerService.getAllTasks();
    } catch (e) {
      print('Ошибка загрузки задач: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          return Column(
            children: [
              const SizedBox(height: 20),
              const MyNavigationBar(currentIndex: 0),
              Expanded(
                child: _buildContent(snapshot),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<List<Task>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _buildErrorWidget(snapshot.error);
    }

    final tasks = snapshot.data ?? [];
    // tasks.sort((a, b) => a.timeLeft.compareTo(b.timeLeft));
    tasks.sort((a, b) => a.title.compareTo(b.title)); // FIX LATER!!!!
    if (tasks.isEmpty) {
      return const Center(child: Text('Нет активных задач'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle.large(text: "Ваши ближайшие дедлайны"),
          _buildDeadlineSection(tasks),
          SectionTitle.large(text: "Все задачи"),
          _buildTaskList(tasks),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDeadlineSection(List<Task> tasks) {
    final nearestTasks = tasks.take(3).toList();
    
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: nearestTasks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) => SizedBox(
          width: 250,
          child: TaskCard(
            task: nearestTasks[index],
            isUrgent: nearestTasks[index].isUrgent,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: tasks
            .map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(
                    task: task,
                    isUrgent: task.isUrgent,
                    showProject: true,
                    showResponsible: false,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            'Ошибка загрузки: ${error?.toString() ?? "Неизвестная ошибка"}',
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
}