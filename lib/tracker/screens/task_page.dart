import 'package:flutter/material.dart';
import 'package:test/tracker/screens/section_title.dart';
import 'navigation_bar.dart';
import '../data/task.dart';

class TaskPage extends StatelessWidget {
  final Task task;

  const TaskPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          MyNavigationBar(
            currentIndex: 1,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaskHeader(),
                  const SizedBox(height: 30),
                  _buildTaskInfoSection(),
                  const SizedBox(height: 30),
                  _buildDescriptionSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle.large(
          text: task.title,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        Row(
          children: [
            Icon(
              Icons.error_outline, 
              color: Colors.orange[700], 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              task.status,
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.work_outline, "Проект:", task.project),
        const SizedBox(height: 15),
        _buildInfoRow(
          Icons.person_outline, 
          "Ответственный:", 
          task.responsible
        ),
        const SizedBox(height: 15),
        _buildInfoRow(
          Icons.calendar_today, 
          "Дедлайн:", 
          "${task.startDate} → ${task.endDate}"
        ),
        const SizedBox(height: 15),
        _buildInfoRow(
          Icons.supervisor_account, 
          "Куратор:", 
          task.curator
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Описание задачи",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          task.description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}