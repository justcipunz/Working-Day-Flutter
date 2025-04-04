import 'package:flutter/material.dart';
import 'navigation_bar.dart';
import 'task.dart';
import 'task_card.dart';

class HomePage extends StatelessWidget {
  final List<Task> tasks = [
    Task("Создать макет в Figma", "09/12/2024", "13/12/2024",
        "Курсовая работа 'Трекер задач'", "Осталось менее 1 часа!", true),
    Task("Создать макет в Figma", "09/12/2024", "13/12/2024",
        "Курсовая работа 'Трекер задач'", "", false),
    Task("Создать макет в Figma", "09/12/2024", "13/12/2024",
        "Курсовая работа 'Трекер задач'", "", false),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const MyNavigationBar(
            currentIndex: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle("Ваши ближайшие дедлайны:"),
                  _buildDeadlineSection(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Все задачи"),
                  _buildTaskList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cera Pro',
        ),
      ),
    );
  }

  Widget _buildDeadlineSection() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) => SizedBox(
          width: 250,
          child: TaskCard(
            task: tasks[index],
            isUrgent: tasks[index].isUrgent,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: tasks
            .map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(
                    task: task,
                    isUrgent: task.isUrgent,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
