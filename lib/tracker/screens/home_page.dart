import 'package:flutter/material.dart';
import 'package:test/user/domain/user_preferences.dart';
import '../domain/tracker_service.dart';
import 'navigation_bar.dart';
import 'section_title.dart';
import '../data/task.dart';
import 'task_card.dart';

// class HomePage extends StatelessWidget {
//   final List<Task> tasks = [
//     Task(
//       id: "1",
//       title: "Создать макет в Figma",
//       startDate: "09/12/2024",
//       endDate: "13/12/2024",
//       projectName: "Курсовая работа 'Трекер задач'",
//       isUrgent: true,
//       assignee: "@akazhkarimov - Асхат Кажкаримов",
//       creator: "@iisypov - Ilya Isypov",
//       status: "В работе",
//       description:
//           "В рамках задачи необходимо разработать анимированный макет...",
//       mediaLinks: List.empty(),
//     ),
//     Task(
//       id: "1",
//       title: "Задача 2",
//       startDate: "09/12/2024",
//       endDate: "13/12/2024",
//       projectName: "Курсовая работа 'Трекер задач'",
//       isUrgent: true,
//       assignee: "@akazhkarimov - Асхат Кажкаримов",
//       creator: "@iisypov - Ilya Isypov",
//       status: "В работе",
//       description:
//           "В рамках задачи необходимо разработать анимированный макет...",
//       mediaLinks: List.empty(),
//     ),
//     Task(
//       id: "1",
//       title: "Создать макет в Figma",
//       startDate: "09/12/2024",
//       endDate: "13/12/2024",
//       projectName: "Мобильное приложение для вуза",
//       isUrgent: true,
//       assignee: "@akazhkarimov - Асхат Кажкаримов",
//       creator: "@iisypov - Ilya Isypov",
//       status: "В работе",
//       description:
//           "Нужно решить задачу №2 по поводу...",
//       mediaLinks: List.empty(),
//     ),
//     Task(
//       id: "1",
//       title: "Задача 3",
//       startDate: "09/12/2024",
//       endDate: "13/12/2024",
//       projectName: "Мобильное приложение для вуза",
//       isUrgent: true,
//       assignee: "@akazhkarimov - Асхат Кажкаримов",
//       creator: "@iisypov - Ilya Isypov",
//       status: "В работе",
//       description:
//           "Нужно решить задачу №2 по поводу...",
//       mediaLinks: List.empty(),
//     ),
//   ];
//   HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           const MyNavigationBar(
//             currentIndex: 0,
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SectionTitle.large(
//                     text: "Ваши ближайшие дедлайны",
//                   ),
//                   _buildDeadlineSection(),
//                   // const SizedBox(height: 20),
//                   SectionTitle.large(
//                     text: "Все задачи",
//                   ),
//                   _buildTaskList(),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDeadlineSection() {
//     return SizedBox(
//       height: 170,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         physics: const BouncingScrollPhysics(),
//         itemCount: tasks.length,
//         separatorBuilder: (context, index) => const SizedBox(width: 15),
//         itemBuilder: (context, index) => SizedBox(
//           width: 250,
//           child: TaskCard(
//             task: tasks[index],
//             isUrgent: tasks[index].isUrgent,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskList() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         children: tasks
//             .map((task) => Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: TaskCard(
//                     task: task,
//                     isUrgent: task.isUrgent,
//                   ),
//                 ))
//             .toList(),
//       ),
//     );
//   }
// }

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
      final tasks = await TrackerService.getAllTasks();
      return tasks;
    } catch (e) {
      print('Ошибка загрузки задач: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Все задачи')),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error);
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text('Нет активных задач'));
          }

          return _buildTaskList(tasks);
        },
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

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          isUrgent: task.isUrgent,
          showProject: true,
          showResponsible: true,
        );
      },
    );
  }
}