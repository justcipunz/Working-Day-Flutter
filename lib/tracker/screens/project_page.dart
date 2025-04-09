import 'package:flutter/material.dart';
import '../data/project.dart';
import '../data/task.dart';
import 'navigation_bar.dart';
import 'project_info.dart';
import 'section_title.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  Project? selectedProject;
  final List<Project> projects = [
    Project(
      name: "Курсовая работа \"Трекер задач\"",
      isAdmin: true,
      tasks: List.generate(
          10,
          (i) => Task(
                title: "Задача ${i + 1}",
                startDate: "09/12/2024",
                endDate: "14/12/2024",
                project: "Курсовая работа \"Трекер задач\"",
                timeLeft: i % 3 == 0 ? "Срочно!" : "",
                isUrgent: i % 3 == 0,
                responsible: "Ответственный ${i + 1}",
                curator: "Куратор ${i + 1}",
                description: "Описание задачи ${i + 1}",
                status: i < 4
                    ? "Новая"
                    : i < 7
                        ? "В работе"
                        : i < 9
                            ? "На рассмотрении"
                            : "Выполнено",
              )),
    ),
    Project(
      name: "Мессенджер ChakChat",
      isAdmin: false,
      tasks: List.generate(
          10,
          (i) => Task(
                title: "Задачакчат ${i + 1}",
                startDate: "${(i * 558) % 30}/12/2024",
                endDate: "${(i * 558) % 30 + 1}/01/2025",
                project: "Мессенджер ChakChat",
                timeLeft: i % 3 == 0 ? "Срочно!" : "",
                isUrgent: i % 3 == 0,
                responsible: "Ответственный ${i + 1}",
                curator: "Куратор ${i + 1}",
                description: "Описание задачи ${i + 1}",
                status: "В работе",
              )),
    ),
    Project(
      name: "Разработка игры на телефон",
      isAdmin: true,
      tasks: [
        Task(
          title: "Создать макет",
          startDate: "09/12/2024",
          endDate: "13/12/2024",
          project: "Курсовая работа",
          status: "Новая",
          timeLeft: "Осталось 3 дня",
          isUrgent: false,
          responsible: "@user1",
          curator: "@curator1",
          description: "Описание задачи",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          const MyNavigationBar(currentIndex: 2),
          Expanded(
            child: selectedProject == null
                ? _buildProjectList()
                : ProjectInfo(
                    project: selectedProject!,
                    onBack: () => setState(() => selectedProject = null),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle.large(text: "Ваши проекты"),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: projects.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                leading: const Icon(Icons.work_outline, size: 32),
                title: Text(projects[index].name),
                subtitle: projects[index].isAdmin
                    ? const Text("Администратор проекта",
                        style: TextStyle(color: Colors.green))
                    : null,
                onTap: () => setState(() => selectedProject = projects[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
