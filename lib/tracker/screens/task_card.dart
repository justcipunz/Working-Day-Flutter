import 'package:flutter/material.dart';
import 'task.dart';
import 'task_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isUrgent;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.isUrgent,
    this.onTap,
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
        onTap: onTap ?? () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TaskPage()),
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
                  // const Icon(Icons.check_box_outline_blank, color: Colors.white),
                  // const SizedBox(width: 8),
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
                  const Icon(Icons.work_outline, size: 16, color: Colors.white),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      task.project,
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
}