import 'package:flutter/material.dart';
import 'project_page.dart';
import 'task.dart';
import 'task_page.dart';
import 'home_page.dart';

class MyNavigationBar extends StatelessWidget {
  final int currentIndex;

  const MyNavigationBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    final page = switch (index) {
      0 => HomePage(),
      1 => TaskPage(
          task: Task(
            title: "Создать макет в Figma",
            startDate: "09/12/2024",
            endDate: "13/12/2024",
            project: "Курсовая работа 'Трекер задач'",
            timeLeft: "Осталось менее 1 часа!",
            isUrgent: true,
            responsible: "@akazhkarimov - Асхат Кажкаримов",
            curator: "@iisypov - Ilya Isypov",
            description:
                "В рамках задачи необходимо разработать анимированный макет...",
          ),
        ),
      2 => ProjectPage(),
      _ => throw Exception('Invalid index'),
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavButton(
          icon: Icons.home,
          isActive: currentIndex == 0,
          onPressed: () => _navigate(context, 0),
        ),
        const SizedBox(width: 20),
        _NavButton(
          icon: Icons.edit,
          isActive: currentIndex == 1,
          onPressed: () => _navigate(context, 1),
        ),
        const SizedBox(width: 20),
        _NavButton(
          icon: Icons.work,
          isActive: currentIndex == 2,
          onPressed: () => _navigate(context, 2),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onPressed,
        // splashColor: const Color(0xFF7A91B8).withOpacity(0.3),
        // highlightColor: const Color(0xFFABABAB).withOpacity(0.2),
        // hoverColor: const Color(0xFFEBECF0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF164F94) : null,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFFABABAB),
            size: 30,
          ),
        ),
      ),
    );
  }
}
