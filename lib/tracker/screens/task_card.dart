import 'package:flutter/material.dart';
import '../data/task.dart';
import 'task_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isUrgent;
  final VoidCallback? onTap;
  final bool showProject;
  final bool showResponsible;

  const TaskCard({
    super.key,
    required this.task,
    required this.isUrgent,
    this.onTap,
    this.showProject = true,
    this.showResponsible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: isUrgent ? const Color(0xFF941616) : const Color(0xFF164F94),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap ?? () => _openTaskDetails(context),
        child: Container(
          padding: const EdgeInsets.all(15),
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: MediaQuery.of(context).size.width - 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cera Pro',
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                  Icons.access_time, "${task.startDate} → ${task.endDate}"),
              _buildInfoRow(Icons.circle, task.status),
              if (showProject)
                _buildInfoRow(Icons.work_outline, task.projectName),
              if (showResponsible)
                _buildInfoRow(Icons.person_outline, task.assignee),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontFamily: 'Cera Pro',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openTaskDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskPage(
                taskId: task.id,
                isAdmin: true, // FIX LATER!!
              )),
    );
  }
}
