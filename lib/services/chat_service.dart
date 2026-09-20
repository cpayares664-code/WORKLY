import '../models/message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Map<String, List<MessageModel>> _cache = {};
  bool _seeded = false;

  void _seed() {
    if (_seeded) return;
    _cache['p1'] = [
      MessageModel(
        id: 'm1',
        projectId: 'p1',
        senderId: 'u2',
        senderName: 'Carlos Ramírez',
        content: 'He terminado el inventario de la Zona 1. Resultados muy prometedores.',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      MessageModel(
        id: 'm2',
        projectId: 'p1',
        senderId: 'u1',
        senderName: 'Dra. Elena Vargas',
        content: 'Excelente trabajo, Carlos. Procedamos con la Zona 2 la próxima semana.',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MessageModel(
        id: 'm3',
        projectId: 'p1',
        senderId: 'u3',
        senderName: 'María López',
        content: 'Tengo listo el equipo de campo para la Zona 2.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
    _seeded = true;
  }

  List<MessageModel> getMessagesForProject(String projectId) {
    _seed();
    final msgs = _cache[projectId] ?? [];
    return List.unmodifiable(List.from(msgs)..sort((a, b) => a.sentAt.compareTo(b.sentAt)));
  }

  Future<void> ensureLoaded(String projectId) async {
    _seed();
  }

  List<MessageModel> getRecentMessages({int limit = 5}) {
    _seed();
    final all = <MessageModel>[];
    for (final msgs in _cache.values) {
      all.addAll(msgs);
    }
    all.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return all.take(limit).toList();
  }

  Future<void> sendMessage(MessageModel message) async {
    _seed();
    final newId = 'm${DateTime.now().millisecondsSinceEpoch}';
    final created = MessageModel(
      id: newId,
      projectId: message.projectId,
      senderId: message.senderId,
      senderName: message.senderName,
      content: message.content,
      isEdited: false,
      sentAt: DateTime.now(),
    );
    _cache.putIfAbsent(message.projectId, () => []);
    _cache[message.projectId]!.add(created);
  }

  int get unreadCount => 0;
}
