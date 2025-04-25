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
      print(tasks[2].projectName);
      return tasks;
    } else {
      throw Exception('Ошибка загрузки задач: ${response.statusCode}');
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

  static Future<List<Project>> getProjects() async {
    final token = await UserPreferences.getToken();
    final response = await http.get(
      Uri.parse('https://working-day.su:8080/v1/tracker/projects/list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['projects'] as List;
      return data.map((json) => Project.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки проектов');
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

  static Future<List<Task>> getUserTasks(String userId) async {
    final token = await UserPreferences.getToken();
    final response = await http.get(
      Uri.parse(
          'https://working-day.su:8080/v1/tracker/tasks/assigned-to-user?employee_id=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['tasks'] as List;
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки задач');
    }
  }
}
