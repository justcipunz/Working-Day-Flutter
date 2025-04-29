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

  static Future<Task> getTaskInfo(String taskId) async {
    final String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    final response = await http.get(
      Uri.parse('https://working-day.su:8080/v1/tracker/tasks/info')
          .replace(queryParameters: {'task_id': taskId}),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Task.fromJson(data);
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception('Некорректный запрос: ${errorData['message']}');
    } else if (response.statusCode == 404) {
      throw Exception('Задача с ID $taskId не найдена');
    } else {
      throw Exception(
          'Ошибка получения информации о задаче: ${response.statusCode}');
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

  static Future<void> createTask({
    required String title,
    required String projectName,
    required String creator,
    String? description,
    String? assignee,
  }) async {
    final String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    final Map<String, dynamic> requestBody = {
      'title': title,
      'project_name': projectName,
      'creator': creator,
      if (description != null) 'description': description,
      if (assignee != null) 'assignee': assignee,
    };

    final response = await http.post(
      Uri.parse('https://working-day.su:8080/v1/tracker/tasks/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    switch (response.statusCode) {
      case 200:
        return;
      case 404:
        final errorData = jsonDecode(response.body);
        throw Exception('Проект не найден: ${errorData['message']}');
      case 400:
        final errorData = jsonDecode(response.body);
        throw Exception('Ошибка валидации: ${errorData['message']}');
      default:
        throw Exception(
            'Ошибка создания задачи: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  static String _convertStatusToApi(String status) {
    switch (status) {
      case 'Новая':
        return 'Open';
      case 'В работе':
        return 'InProgress';
      case 'На рассмотрении':
        return 'Review';
      case 'Выполнено':
        return 'Done';
      default:
        return 'Open';
    }
  }

  static Future<void> editTask({
    required String taskId,
    String? title,
    String? description,
    String? projectName,
    String? assignee,
    String? status,
  }) async {
    final String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен авторизации отсутствует');
    }

    final Map<String, dynamic> requestBody = {};
    if (title != null) requestBody['title'] = title;
    if (description != null) requestBody['description'] = description;
    if (projectName != null) requestBody['project_name'] = projectName;
    if (assignee != null) requestBody['assignee'] = assignee;
    if (status != null) requestBody['status'] = _convertStatusToApi(status);

    final response = await http.post(
      Uri.parse('https://working-day.su:8080/v1/tracker/tasks/edit')
          .replace(queryParameters: {'task_id': taskId}),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    switch (response.statusCode) {
      case 200:
        return;
      case 400:
        final errorData = jsonDecode(response.body);
        throw Exception('Ошибка валидации: ${errorData['message']}');
      case 404:
        final errorData = jsonDecode(response.body);
        throw Exception('Задача не найдена: ${errorData['message']}');
      default:
        throw Exception(
            'Ошибка обновления задачи: ${response.statusCode} ${response.reasonPhrase}');
    }
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
