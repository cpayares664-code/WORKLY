import 'package:flutter/material.dart';

import '../../models/message_model.dart';
import '../../models/project_model.dart';
import '../../services/chat_service.dart';
import '../../services/project_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../app_scaffold.dart';

class ProjectChatScreen extends StatefulWidget {
  const ProjectChatScreen({super.key});

  @override
  State<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends State<ProjectChatScreen> {
  final _chatService = ChatService();
  final _projectService = ProjectService();
  final _messageController = TextEditingController();
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    final projects = _projectService.getAllProjects();
    if (projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = _projectService.getAllProjects();
    final messages =
        _selectedProjectId != null ? _chatService.getMessagesForProject(_selectedProjectId!) : <MessageModel>[];
    final selectedProject = _selectedProjectId != null
        ? _projectService.getProjectById(_selectedProjectId!)
        : null;

    return AppScaffold(
      title: 'Chat de Proyecto',
      currentIndex: 4,
      body: Row(
        children: [
          // Project list sidebar
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimens.spaceLg),
                  child: Text(
                    'Proyectos',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (_, i) {
                      final p = projects[i];
                      final isSelected = p.id == _selectedProjectId;
                      final projectMessages = _chatService.getMessagesForProject(p.id);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedProjectId = p.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.spaceLg,
                              vertical: AppDimens.spaceMd,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.08) : null,
                              border: Border(
                                left: BorderSide(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Helpers.truncate(p.title, 28),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${projectMessages.length} mensajes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Chat area
          Expanded(
            child: selectedProject == null
                ? const EmptyState(icon: Icons.chat, title: 'Selecciona un proyecto')
                : Column(
                    children: [
                      _buildChatHeader(selectedProject),
                      Expanded(
                        child: messages.isEmpty
                            ? const EmptyState(
                                icon: Icons.chat_bubble_outline,
                                title: 'Sin mensajes',
                                message: 'Sé el primero en escribir en este chat.',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(AppDimens.spaceLg),
                                itemCount: messages.length,
                                itemBuilder: (_, i) => _buildMessageBubble(messages[i]),
                              ),
                      ),
                      _buildMessageInput(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader(ProjectModel project) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceLg,
        vertical: AppDimens.spaceMd,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: const Icon(Icons.folder, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppDimens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${project.memberIds.length} miembros',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.people_outline, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMe = message.senderId == 'u1';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spaceMd),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                Helpers.initialsFromName(message.senderName),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.spaceSm),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.45,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceMd,
                vertical: AppDimens.spaceSm + 2,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimens.radiusM),
                  topRight: const Radius.circular(AppDimens.radiusM),
                  bottomLeft: Radius.circular(isMe ? AppDimens.radiusM : 4),
                  bottomRight: Radius.circular(isMe ? 4 : AppDimens.radiusM),
                ),
                border: isMe ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Helpers.formatTime(message.sentAt)}${message.isEdited ? ' · editado' : ''}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white.withOpacity(0.7) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceMd),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: AppColors.textMuted),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: AppColors.background,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppDimens.spaceSm),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedProjectId == null) return;

    final message = MessageModel(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      projectId: _selectedProjectId!,
      senderId: 'u1',
      senderName: 'Dra. Elena Vargas',
      content: _messageController.text.trim(),
      sentAt: DateTime.now(),
    );

    _chatService.sendMessage(message);
    _messageController.clear();
    setState(() {});
  }
}
