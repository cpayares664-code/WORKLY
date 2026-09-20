import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel> _cache = [];
  bool _loaded = false;

  void _seed() {
    if (_loaded) return;
    _cache.addAll([
      NotificationModel(
        id: 'n1',
        type: NotificationType.taskAssigned,
        title: 'Nueva tarea asignada',
        body: 'Se te ha asignado "Recolectar muestras Zona 2".',
        projectId: 'p1',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.deadlineReminder,
        title: 'Fecha límite próxima',
        body: 'La tarea "Encuestas de campo" vence en 2 días.',
        projectId: 'p3',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'n3',
        type: NotificationType.projectUpdate,
        title: 'Proyecto actualizado',
        body: 'El proyecto "Estudio de Biodiversidad" ha alcanzado 45% de progreso.',
        projectId: 'p1',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 'n4',
        type: NotificationType.messageReceived,
        title: 'Nuevo mensaje',
        body: 'Carlos ha enviado un mensaje en el chat del proyecto.',
        projectId: 'p1',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
    _loaded = true;
  }

  List<NotificationModel> getAllNotifications() {
    _seed();
    final sorted = List<NotificationModel>.from(_cache)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  List<NotificationModel> getUnreadNotifications() {
    return getAllNotifications().where((n) => !n.isRead).toList();
  }

  Future<void> markAsRead(String id) async {
    final idx = _cache.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _cache[idx] = _cache[idx].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _cache.length; i++) {
      _cache[i] = _cache[i].copyWith(isRead: true);
    }
  }

  int get unreadCount => _cache.where((n) => !n.isRead).length;

  Future<void> refresh() async {
    _seed();
  }
}
