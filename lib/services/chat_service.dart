import 'dart:convert';
import '../models/message_model.dart';
import 'api_client.dart';

class ChatService {
  static const String _resource = '/messages';

  final Map<String, List<MessageModel>> _cache = {};

  Future<List<MessageModel>> _getForProject(String projectId) async {
    if (_cache.containsKey(projectId)) return _cache[projectId]!;
    final res = await ApiClient.get('$_resource/$projectId');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      _cache[projectId] = list.map((j) => _fromApi(j as Map<String, dynamic>)).toList();
    } else {
      _cache[projectId] = [];
    }
    return _cache[projectId]!;
  }

  List<MessageModel> getMessagesForProject(String projectId) {
    final msgs = _cache[projectId] ?? [];
    return List.unmodifiable(msgs..sort((a, b) => a.sentAt.compareTo(b.sentAt)));
  }

  Future<void> ensureLoaded(String projectId) async {
    await _getForProject(projectId);
  }

  List<MessageModel> getRecentMessages({int limit = 5}) {
    final all = <MessageModel>[];
    for (final msgs in _cache.values) {
      all.addAll(msgs);
    }
    all.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return all.take(limit).toList();
  }

  Future<void> sendMessage(MessageModel message) async {
    final res = await ApiClient.post(_resource, body: _toApi(message));
    if (res.statusCode == 201) {
      final created = _fromApi(jsonDecode(res.body) as Map<String, dynamic>);
      _cache.putIfAbsent(message.projectId, () => []);
      _cache[message.projectId]!.add(created);
    } else {
      _cache.putIfAbsent(message.projectId, () => []);
      _cache[message.projectId]!.add(message);
    }
  }

  int get unreadCount => 0;

  MessageModel _fromApi(Map<String, dynamic> j) {
    return MessageModel(
      id: j['_id'] as String? ?? j['id'] as String,
      projectId: j['projectId'] as String,
      senderId: j['senderId'] as String,
      senderName: j['senderName'] as String,
      content: j['content'] as String,
      isEdited: j['isEdited'] as bool? ?? false,
      sentAt: DateTime.tryParse(j['sentAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _toApi(MessageModel m) => {
        'projectId': m.projectId,
        'senderId': m.senderId,
        'senderName': m.senderName,
        'content': m.content,
        'isEdited': m.isEdited,
        'sentAt': m.sentAt.toIso8601String(),
      };
}
