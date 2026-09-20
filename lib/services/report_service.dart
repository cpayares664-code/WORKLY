import '../models/report_model.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final List<ReportModel> _cache = [];
  bool _loaded = false;

  void _seed() {
    if (_loaded) return;
    _cache.addAll([
      ReportModel(
        id: 'r1',
        projectId: 'p1',
        title: 'Informe de Avance Q1 2025',
        summary: 'Se completó la recolección en la Zona 1 y se inició la Zona 2.',
        authorId: 'u1',
        authorName: 'Dra. Elena Vargas',
        progressBefore: 30,
        progressAfter: 45,
        highlights: ['Inventario Zona 1 completo', 'Nueva especie identificada'],
        challenges: ['Condiciones climáticas adversas'],
        nextSteps: ['Iniciar análisis preliminar', 'Preparar Zona 3'],
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 3, 31),
        createdAt: DateTime(2025, 4, 5),
      ),
      ReportModel(
        id: 'r2',
        projectId: 'p3',
        title: 'Informe de Campo - Comunidades',
        summary: 'Se aplicaron encuestas en 5 comunidades rurales.',
        authorId: 'u1',
        authorName: 'Dra. Elena Vargas',
        progressBefore: 50,
        progressAfter: 60,
        highlights: ['120 encuestas completadas', 'Alta participación'],
        challenges: ['Dificultad de acceso a zonas remotas'],
        nextSteps: ['Análisis de datos', 'Informe final'],
        periodStart: DateTime(2024, 9, 1),
        periodEnd: DateTime(2024, 12, 31),
        createdAt: DateTime(2025, 1, 10),
      ),
    ]);
    _loaded = true;
  }

  List<ReportModel> getAllReports() {
    _seed();
    final sorted = List<ReportModel>.from(_cache)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  List<ReportModel> getReportsForProject(String projectId) {
    _seed();
    return _cache.where((r) => r.projectId == projectId).toList();
  }

  Future<void> addReport(ReportModel report) async {
    final newId = 'r${DateTime.now().millisecondsSinceEpoch}';
    final created = ReportModel(
      id: newId,
      projectId: report.projectId,
      title: report.title,
      summary: report.summary,
      authorId: report.authorId,
      authorName: report.authorName,
      progressBefore: report.progressBefore,
      progressAfter: report.progressAfter,
      highlights: report.highlights,
      challenges: report.challenges,
      nextSteps: report.nextSteps,
      periodStart: report.periodStart,
      periodEnd: report.periodEnd,
      createdAt: DateTime.now(),
    );
    _cache.insert(0, created);
  }

  Future<void> deleteReport(String id) async {
    _cache.removeWhere((r) => r.id == id);
  }

  int get totalReports => _cache.length;

  Future<void> refresh() async {
    _seed();
  }
}
