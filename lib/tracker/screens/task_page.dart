import 'package:flutter/material.dart';
import 'package:test/user/domain/user_preferences.dart';
import '../domain/tracker_service.dart';
import '../data/task.dart';
import 'section_title.dart';
import 'navigation_bar.dart';

enum TaskPageMode { view, edit, create }

class TaskPage extends StatefulWidget {
  final String? taskId;
  final bool isAdmin;

  const TaskPage({
    super.key,
    this.taskId,
    required this.isAdmin,
  });

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late TaskPageMode _mode;
  late Task _task;
  bool _isLoading = false;
  String? _errorMessage;

  final _titleController = TextEditingController();
  final _projectController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mode = TaskPageMode.view;
    _task = Task.empty();

    if (widget.taskId != null) {
      _loadTask();
    } else {
      _mode = TaskPageMode.create;
      _initializeEmptyTask();
    }
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final task = await TrackerService.getTaskInfo(widget.taskId!);
      setState(() => _task = task);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeEmptyTask() async {
    final me = await UserPreferences.fetchProfileInfo();
    setState(() {
      _task = Task.empty().copyWith(
        creator: me.id ?? 'Неизвестный',
      );
    });
  }

  Future<void> _saveChanges() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await TrackerService.editTask(
        taskId: _task.id,
        title: _titleController.text,
        projectName: _projectController.text,
        assignee: _assigneeController.text,
        description: _descriptionController.text,
      );
      setState(() {
        _mode = TaskPageMode.view;
        _task = _task.copyWith(
          title: _titleController.text,
          projectName: _projectController.text,
          assignee: _assigneeController.text,
          description: _descriptionController.text,
        );
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTask() async {
    if (!_validateFields()) return;

    final me = await UserPreferences.fetchProfileInfo();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await TrackerService.createTask(
        title: _titleController.text,
        projectName: _projectController.text,
        creator: me.id ?? 'Неизвестный',
        assignee: _assigneeController.text,
        description: _descriptionController.text,
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateFields() {
    if (_titleController.text.isEmpty || _projectController.text.isEmpty) {
      setState(() => _errorMessage = 'Заполните обязательные поля*');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          const MyNavigationBar(currentIndex: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: () =>
                  _mode == TaskPageMode.create ? _createTask() : _loadTask(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _mode == TaskPageMode.view ? _buildViewMode() : _buildEditMode(),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTaskHeader(),
        const SizedBox(height: 30),
        _buildTaskInfoSection(),
        const SizedBox(height: 30),
        _buildDescriptionSection(),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle.large(
          text: _mode == TaskPageMode.edit
              ? "Редактировать задачу"
              : "Создать задачу",
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        _buildEditableField('Название*', _titleController),
        const SizedBox(height: 20),
        _buildEditableField('Проект*', _projectController),
        const SizedBox(height: 20),
        _buildEditableField('Ответственный', _assigneeController),
        const SizedBox(height: 20),
        _buildEditableField('Описание', _descriptionController, maxLines: 5),
      ],
    );
  }

  Widget _buildTaskHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle.large(
          text: _task.title,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              _task.status,
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
        _buildInfoRow(Icons.work_outline, "Проект:", _task.projectName),
        const SizedBox(height: 15),
        _buildInfoRow(Icons.person_outline, "Ответственный:", _task.assignee),
        const SizedBox(height: 15),
        _buildInfoRow(Icons.calendar_today, "Дедлайн:",
            "${_task.startDate} → ${_task.endDate}"),
        const SizedBox(height: 15),
        _buildInfoRow(Icons.supervisor_account, "Куратор:", _task.creator),
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
          _task.description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller..text = _getFieldValue(label),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  String _getFieldValue(String label) {
    switch (label) {
      case 'Название*':
        return _task.title;
      case 'Проект*':
        return _task.projectName;
      case 'Ответственный':
        return _task.assignee;
      case 'Описание':
        return _task.description;
      default:
        return '';
    }
  }

  Widget? _buildFloatingActionButton() {
    if (_mode == TaskPageMode.view && widget.isAdmin) {
      return FloatingActionButton(
        onPressed: () => setState(() {
          _titleController.text = _task.title;
          _projectController.text = _task.projectName;
          _assigneeController.text = _task.assignee;
          _descriptionController.text = _task.description;
          _mode = TaskPageMode.edit;
        }),
        child: const Icon(Icons.edit),
      );
    }

    if (_mode != TaskPageMode.view) {
      return FloatingActionButton(
        onPressed: _mode == TaskPageMode.edit ? _saveChanges : _createTask,
        child: const Icon(Icons.save),
      );
    }

    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _projectController.dispose();
    _assigneeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
