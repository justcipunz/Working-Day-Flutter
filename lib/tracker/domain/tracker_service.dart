import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/user/domain/user_preferences.dart';
import '../data/task.dart';
import '../data/project.dart';

class TrackerService {
  static Future<List<Task>> getAllTasks() async {
    final String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    final response = await http.get(
      Uri.parse('https://working-day.su:8080/v1/tracker/tasks/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> tasksJson = data['tasks'];
      print(tasksJson);
      var tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
      return tasks;
    } else {
      throw Exception(
          'Ошибка загрузки задач ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  static Future<List<Task>> getAssignedTasks(String employeeId) async {
    final String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    try {
      final response = await http.get(
        Uri.parse(
                'https://working-day.su:8080/v1/tracker/tasks/assigned_to_user')
            .replace(queryParameters: {'employee_id': employeeId}),
        headers: {'Authorization': 'Bearer $token'},
      );

      switch (response.statusCode) {
        case 200:
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> tasksJson = data['tasks'];
          return tasksJson.map((json) => Task.fromJson(json)).toList();

        case 400:
          final error =
              jsonDecode(response.body)['message'] ?? 'Неверный запрос';
          throw Exception('Ошибка 400: $error');

        case 404:
          throw Exception('Задачи для пользователя $employeeId не найдены');

        default:
          throw Exception(
              'Ошибка ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on FormatException {
      throw Exception('Ошибка формата ответа от сервера');
    } on http.ClientException {
      throw Exception('Проблема с подключением к серверу');
    }
  }

  static Future<List<Project>> getAllProjects() async {
    final String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    final response = await http.get(
      Uri.parse('https://working-day.su:8080/v1/tracker/projects/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> projectsJson = data['projects'];
      print(projectsJson);
      final projectsList =
          projectsJson.map((json) => Project.fromJson(json)).toList();
      return projectsList;
    } else {
      throw Exception(
          'Ошибка загрузки проектов ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  static Future<List<Task>> getTasksByProject(String projectName) async {
    final allTasks = await getAllTasks();
    final tasksByProject =
        allTasks.where((task) => task.projectName == projectName).toList();
    for (var task in tasksByProject) {
      print(task);
    }
    return tasksByProject;
  }

  static Future<void> createProject(String projectName) async {
    final token = await UserPreferences.getToken();
    final response = await http.post(
      Uri.parse('https://working-day.su:8080/v1/tracker/projects/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'project_name': projectName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка создания проекта');
    }
  }
}
