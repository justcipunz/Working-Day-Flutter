import 'package:flutter/material.dart';
import '../../user/domain/user_preferences.dart';
import '../data/project.dart';
import '../data/task.dart';
import '../domain/tracker_service.dart';
import 'navigation_bar.dart';
import 'project_info.dart';
import 'section_title.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late Future<List<Project>> _projectsFuture;
  Project? selectedProject;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _loadProjects();
  }

  Future<List<Project>> _loadProjects() async {
    try {
      return await TrackerService.getAllProjects();
    } catch (e) {
      print('Ошибка загрузки проектов: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          return Column(
            children: [
              const SizedBox(height: 20),
              const MyNavigationBar(currentIndex: 2),
              Expanded(
                child: _buildContent(snapshot),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<List<Project>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _buildErrorWidget(snapshot.error);
    }

    final projects = snapshot.data ?? [];
    if (projects.isEmpty) {
      return const Center(child: Text('Нет доступных проектов'));
    }

    return selectedProject == null
        ? _buildProjectList(projects)
        : ProjectInfo(
            project: selectedProject!,
            onBack: () => setState(() => selectedProject = null),
          );
  }

  Widget _buildProjectList(List<Project> projects) {
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

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            'Ошибка загрузки проектов: ${error?.toString() ?? "Неизвестная ошибка"}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _projectsFuture = _loadProjects()),
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }
}
