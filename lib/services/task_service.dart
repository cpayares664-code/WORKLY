import '../models/task_model.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final List<TaskModel> _cache = [];
  bool _loaded = false;

  void _seed() {
    if (_loaded) return;
    _cache.addAll([
      TaskModel(
        id: 't1',
        projectId: 'p1',
        title: 'Recolectar muestras Zona 1',
        description: 'Recolección de muestras biológicas en la zona 1.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        assigneeId: 'u1',
        dueDate: DateTime(2025, 3, 15),
        subtasks: ['Preparar equipo', 'Transportar muestras', 'Catalogar'],
        completedSubtasks: 3,
        createdAt: DateTime(2025, 1, 20),
      ),
      TaskModel(
        id: 't2',
        projectId: 'p1',
        title: 'Recolectar muestras Zona 2',
        description: 'Recolección en la zona 2 del estudio.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        assigneeId: 'u1',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        subtasks: ['Preparar equipo', 'Transportar muestras', 'Catalogar'],
        completedSubtasks: 1,
        createdAt: DateTime(2025, 2, 1),
      ),
      TaskModel(
        id: 't3',
        projectId: 'p1',
        title: 'Análisis preliminar de datos',
        description: 'Primer análisis estadístico de los datos recolectados.',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        assigneeId: 'u2',
        dueDate: DateTime.now().add(const Duration(days: 12)),
        subtasks: [],
        completedSubtasks: 0,
        createdAt: DateTime(2025, 2, 15),
      ),
      TaskModel(
        id: 't4',
        projectId: 'p2',
        title: 'Revisión bibliográfica',
        description: 'Revisión de literatura sobre nanomateriales solares.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        assigneeId: 'u1',
        dueDate: DateTime.now().add(const Duration(days: 8)),
        subtasks: ['Buscar papers', 'Resumir hallazgos'],
        completedSubtasks: 1,
        createdAt: DateTime(2025, 5, 25),
      ),
      TaskModel(
        id: 't5',
        projectId: 'p3',
        title: 'Encuestas de campo',
        description: 'Aplicar encuestas en comunidades rurales.',
        status: TaskStatus.review,
        priority: TaskPriority.urgent,
        assigneeId: 'u1',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        subtasks: ['Diseñar encuesta', 'Piloto', 'Aplicar'],
        completedSubtasks: 2,
        createdAt: DateTime(2024, 10, 1),
      ),
    ]);
    _loaded = true;
  }

  List<TaskModel> getAllTasks() {
    _seed();
    return List.unmodifiable(_cache);
  }

  List<TaskModel> getTasksForProject(String projectId) {
    _seed();
    return _cache.where((t) => t.projectId == projectId).toList();
  }

  List<TaskModel> getTasksByStatus(TaskStatus status) {
    _seed();
    return _cache.where((t) => t.status == status).toList();
  }

  List<TaskModel> getTasksByAssignee(String userId) {
    _seed();
    return _cache.where((t) => t.assigneeId == userId).toList();
  }

  List<TaskModel> getOverdueTasks() {
    _seed();
    return _cache.where((t) => t.isOverdue).toList();
  }

  List<TaskModel> getUpcomingTasks({int days = 7}) {
    _seed();
    final limit = DateTime.now().add(Duration(days: days));
    return _cache.where((t) {
      if (t.dueDate == null || t.status == TaskStatus.done) return false;
      return t.dueDate!.isBefore(limit);
    }).toList();
  }

  Future<void> addTask(TaskModel task) async {
    final newId = 't${DateTime.now().millisecondsSinceEpoch}';
    final created = TaskModel(
      id: newId,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      subtasks: task.subtasks,
      completedSubtasks: task.completedSubtasks,
      createdAt: DateTime.now(),
    );
    _cache.insert(0, created);
  }

  Future<void> updateTask(TaskModel task) async {
    final idx = _cache.indexWhere((t) => t.id == task.id);
    if (idx != -1) _cache[idx] = task;
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final idx = _cache.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _cache[idx] = _cache[idx].copyWith(status: status);
    }
  }

  Future<void> deleteTask(String id) async {
    _cache.removeWhere((t) => t.id == id);
  }

  int get totalTasks => _cache.length;

  int get completedTasks =>
      _cache.where((t) => t.status == TaskStatus.done).length;

  int get overdueCount => getOverdueTasks().length;

  double get completionRate {
    if (_cache.isEmpty) return 0;
    return completedTasks / _cache.length * 100;
  }

  Future<void> refresh() async {
    _seed();
  }
}
