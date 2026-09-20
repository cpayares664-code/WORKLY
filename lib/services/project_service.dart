import '../models/project_model.dart';
import '../models/objective_model.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final List<ProjectModel> _cache = [];
  final List<ObjectiveModel> _objectivesCache = [];
  bool _loaded = false;

  void _seed() {
    if (_loaded) return;
    _cache.addAll([
      ProjectModel(
        id: 'p1',
        title: 'Estudio de Biodiversidad en los Andes',
        description: 'Análisis de la diversidad de especies en ecosistemas de alta montaña.',
        area: 'Ecología',
        status: ProjectStatus.active,
        leadId: 'u1',
        memberIds: ['u1', 'u2', 'u3'],
        startDate: DateTime(2025, 1, 15),
        endDate: DateTime(2026, 12, 31),
        budget: 75000,
        spent: 32000,
        progress: 45,
        tags: ['Clima', 'Biodiversidad', 'Andes'],
        createdAt: DateTime(2025, 1, 10),
      ),
      ProjectModel(
        id: 'p2',
        title: 'Nanomateriales para Energía Renovable',
        description: 'Desarrollo de nuevos nanomateriales para celdas solares de alta eficiencia.',
        area: 'Nanotecnología',
        status: ProjectStatus.planning,
        leadId: 'u1',
        memberIds: ['u1', 'u4'],
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2027, 6, 1),
        budget: 120000,
        spent: 5000,
        progress: 10,
        tags: ['Energía', 'Nanotecnología'],
        createdAt: DateTime(2025, 5, 20),
      ),
      ProjectModel(
        id: 'p3',
        title: 'Salud Pública y Cambio Climático',
        description: 'Impacto del cambio climático en la salud de comunidades rurales.',
        area: 'Salud Pública',
        status: ProjectStatus.onHold,
        leadId: 'u2',
        memberIds: ['u1', 'u2', 'u5'],
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2026, 3, 1),
        budget: 50000,
        spent: 28000,
        progress: 60,
        tags: ['Salud', 'Clima', 'Rural'],
        createdAt: DateTime(2024, 8, 15),
      ),
    ]);

    _objectivesCache.addAll([
      ObjectiveModel(
        id: 'o1',
        projectId: 'p1',
        title: 'Inventario de especies',
        description: 'Completar el inventario de especies en 3 zonas de estudio.',
        status: ObjectiveStatus.inProgress,
        weight: 1.0,
        targetDate: DateTime(2025, 12, 31),
        milestones: ['Zona 1', 'Zona 2', 'Zona 3'],
        completedMilestones: 2,
        createdAt: DateTime(2025, 1, 15),
      ),
      ObjectiveModel(
        id: 'o2',
        projectId: 'p1',
        title: 'Análisis estadístico',
        description: 'Análisis de datos de biodiversidad.',
        status: ObjectiveStatus.notStarted,
        weight: 0.8,
        targetDate: DateTime(2026, 6, 30),
        milestones: ['Recopilación', 'Procesamiento', 'Reporte'],
        completedMilestones: 0,
        createdAt: DateTime(2025, 1, 15),
      ),
    ]);

    _loaded = true;
  }

  List<ProjectModel> getAllProjects() {
    _seed();
    return List.unmodifiable(_cache);
  }

  ProjectModel? getProjectById(String id) {
    _seed();
    try {
      return _cache.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ObjectiveModel> getObjectivesForProject(String projectId) {
    _seed();
    return _objectivesCache.where((o) => o.projectId == projectId).toList();
  }

  List<ProjectModel> getProjectsByStatus(ProjectStatus status) {
    _seed();
    return _cache.where((p) => p.status == status).toList();
  }

  Future<void> addProject(ProjectModel project) async {
    final newId = 'p${DateTime.now().millisecondsSinceEpoch}';
    final created = ProjectModel(
      id: newId,
      title: project.title,
      description: project.description,
      area: project.area,
      status: project.status,
      leadId: project.leadId,
      memberIds: project.memberIds,
      startDate: project.startDate,
      endDate: project.endDate,
      budget: project.budget,
      spent: project.spent,
      progress: project.progress,
      tags: project.tags,
      createdAt: DateTime.now(),
    );
    _cache.insert(0, created);
  }

  Future<void> updateProject(ProjectModel project) async {
    final idx = _cache.indexWhere((p) => p.id == project.id);
    if (idx != -1) _cache[idx] = project;
  }

  Future<void> deleteProject(String id) async {
    _cache.removeWhere((p) => p.id == id);
    _objectivesCache.removeWhere((o) => o.projectId == id);
  }

  int get totalProjects => _cache.length;

  int get activeProjects =>
      _cache.where((p) => p.status == ProjectStatus.active).length;

  double get totalBudget =>
      _cache.fold(0, (sum, p) => sum + p.budget);

  double get totalSpent =>
      _cache.fold(0, (sum, p) => sum + p.spent);

  double get averageProgress {
    if (_cache.isEmpty) return 0;
    return _cache.fold(0, (sum, p) => sum + p.progress) / _cache.length;
  }

  Future<void> refresh() async {
    _seed();
  }
}
