import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../services/project_service.dart';
import '../../services/task_service.dart';
import '../../services/report_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/metric_card.dart';
import '../app_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _projectService = ProjectService();
  final _taskService = TaskService();
  final _reportService = ReportService();

  UserModel _user = UserModel(
    id: 'u1',
    name: 'Dra. Elena Vargas',
    email: 'elena.vargas@universidad.edu',
    institution: 'Universidad Nacional de Investigación',
    role: UserRole.principalInvestigator,
    projectIds: [],
    createdAt: DateTime(2020, 3, 15),
  );

  @override
  void initState() {
    super.initState();
    _user = UserModel(
      id: 'u1',
      name: 'Dra. Elena Vargas',
      email: 'elena.vargas@universidad.edu',
      institution: 'Universidad Nacional de Investigación',
      role: UserRole.principalInvestigator,
      projectIds: _projectService.getAllProjects().map((p) => p.id).toList(),
      createdAt: DateTime(2020, 3, 15),
    );
  }

  void _goToEdit() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editProfile,
      arguments: _user,
    );
    if (result is UserModel && mounted) {
      setState(() => _user = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myTasks = _taskService.getTasksByAssignee(_user.id);
    final myReports = _reportService.getAllReports().where((r) => r.authorId == _user.id).toList();
    final myProjects = _projectService.getAllProjects().where((p) => p.leadId == _user.id).toList();

    return AppScaffold(
      title: 'Perfil',
      currentIndex: 8,
      actions: [
        IconButton(
          onPressed: _goToEdit,
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Editar perfil',
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppDimens.spaceXl),
            // Stats
            LayoutBuilder(builder: (context, constraints) {
              final count = constraints.maxWidth > 700 ? 4 : 2;
              final spacing = AppDimens.spaceMd;
              final w = (constraints.maxWidth - spacing * (count - 1)) / count;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: w,
                    child: MetricCard(
                      label: 'Proyectos Liderados',
                      value: '${myProjects.length}',
                      icon: Icons.folder_open,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: MetricCard(
                      label: 'Tareas Asignadas',
                      value: '${myTasks.length}',
                      icon: Icons.checklist_rtl,
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: MetricCard(
                      label: 'Informes Creados',
                      value: '${myReports.length}',
                      icon: Icons.assessment,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: MetricCard(
                      label: 'Tareas Completadas',
                      value: '${myTasks.where((t) => t.status == TaskStatus.done).length}',
                      icon: Icons.task_alt,
                      color: AppColors.success,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppDimens.spaceXl),
            // Personal info
            const Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.spaceMd),
            _buildInfoCard(),
            const SizedBox(height: AppDimens.spaceXl),
            // Settings
            const Text(
              'Configuración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimens.spaceMd),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
            ),
            child: Center(
              child: Text(
                _user.initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Text(
                    _user.role.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _user.institution ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Correo', _user.email),
          const Divider(height: AppDimens.spaceXl),
          _buildInfoRow(Icons.school_outlined, 'Institución', _user.institution ?? 'No especificada'),
          const Divider(height: AppDimens.spaceXl),
          _buildInfoRow(Icons.badge_outlined, 'Rol', _user.role.label),
          const Divider(height: AppDimens.spaceXl),
          _buildInfoRow(Icons.folder_outlined, 'Proyectos', '${_user.projectIds.length} proyectos'),
          const Divider(height: AppDimens.spaceXl),
          _buildInfoRow(Icons.calendar_today_outlined, 'Miembro desde', Helpers.formatDate(_user.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppDimens.spaceMd),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
      child: Column(
        children: [
          _buildSettingItem(Icons.notifications_outlined, 'Notificaciones', 'Configurar alertas'),
          _buildSettingItem(Icons.lock_outline, 'Privacidad', 'Gestionar permisos'),
          _buildSettingItem(Icons.palette_outlined, 'Apariencia', 'Tema claro/oscuro'),
          _buildSettingItem(Icons.language_outlined, 'Idioma', 'Español'),
          _buildSettingItem(Icons.help_outline, 'Ayuda', 'Soporte y documentación'),
          _buildSettingItem(Icons.logout, 'Cerrar Sesión', null, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String? subtitle, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceLg,
            vertical: AppDimens.spaceMd + 2,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: isDestructive ? AppColors.error : AppColors.textSecondary),
              const SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              if (!isDestructive)
                Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
