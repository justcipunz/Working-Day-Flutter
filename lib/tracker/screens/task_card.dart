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
        onTap: onTap ??
            () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskPage(task: task)),
                ),
        child: Container(
          padding: const EdgeInsets.all(15),
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: MediaQuery.of(context).size.width - 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cera Pro',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.white),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      "${task.startDate} → ${task.endDate}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Cera Pro',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.white),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      task.status,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Cera Pro',
                      ),
                    ),
                  ),
                ],
              ),
              if (showProject || showResponsible) const SizedBox(height: 8),
              if (showProject)
                _buildInfoRow(
                  icon: Icons.work_outline,
                  text: task.project,
                ),
              if (showResponsible)
                _buildInfoRow(
                  icon: Icons.person_outline,
                  text: task.responsible,
                ),
              if (isUrgent && task.timeLeft.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    task.timeLeft,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cera Pro',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontFamily: 'Cera Pro',
            ),
          ),
        ),
      ],
    );
  }
}
