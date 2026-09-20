import 'package:flutter/material.dart';

import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../models/document_model.dart';
import '../../models/report_model.dart';
import '../../models/objective_model.dart';
import '../../services/project_service.dart';
import '../../services/task_service.dart';
import '../../services/document_service.dart';
import '../../services/report_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/task_card.dart';
import '../../widgets/document_card.dart';
import '../../widgets/budget_chart.dart';
import '../../widgets/empty_state.dart';
import '../app_scaffold.dart';

class ProjectWorkspaceScreen extends StatefulWidget {
  final String projectId;

  const ProjectWorkspaceScreen({super.key, required this.projectId});

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  final _projectService = ProjectService();
  final _taskService = TaskService();
  final _documentService = DocumentService();
  final _reportService = ReportService();

  late TabController _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _projectService.refresh(),
      _taskService.refresh(),
      _documentService.refresh(),
      _reportService.refresh(),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppScaffold(
        title: 'Proyecto',
        currentIndex: 1,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final project = _projectService.getProjectById(widget.projectId);

    if (project == null) {
      return AppScaffold(
        title: 'Proyecto no encontrado',
        currentIndex: 1,
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Proyecto no encontrado',
          message: 'El proyecto que buscas no existe o fue eliminado.',
        ),
      );
    }

    final tasks = _taskService.getTasksForProject(project.id);
    final documents = _documentService.getDocumentsForProject(project.id);
    final objectives = _projectService.getObjectivesForProject(project.id);
    final reports = _reportService.getReportsForProject(project.id);

    return AppScaffold(
      title: Helpers.truncate(project.title, 30),
      currentIndex: 1,
      body: Column(
        children: [
          _buildProjectHeader(project),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Resumen'),
              Tab(text: 'Tareas'),
              Tab(text: 'Documentos'),
              Tab(text: 'Objetivos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(project, reports),
                _buildTasksTab(tasks),
                _buildDocumentsTab(documents),
                _buildObjectivesTab(objectives),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHeader(ProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(project.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                child: Text(
                  project.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(project.status),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.spaceSm),
              if (project.area != null)
                Text(
                  project.area!,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),
          Text(
            project.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),
          Row(
            children: [
              Text(
                'Progreso: ${project.progress}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppDimens.spaceMd),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: project.progress / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(_statusColor(project.status)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm),
          Row(
            children: [
              _buildInfoChip(Icons.people_outline, '${project.memberIds.length} miembros'),
              const SizedBox(width: AppDimens.spaceMd),
              _buildInfoChip(Icons.calendar_today, Helpers.formatDateShort(project.startDate)),
              const SizedBox(width: AppDimens.spaceMd),
              _buildInfoChip(
                Icons.attach_money,
                '${Helpers.formatCurrency(project.spent)} / ${Helpers.formatCurrency(project.budget)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.success;
      case ProjectStatus.planning:
        return AppColors.info;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.primary;
      case ProjectStatus.cancelled:
        return AppColors.error;
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildSummaryTab(ProjectModel project, List<ReportModel> reports) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Presupuesto vs. Gastado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(AppDimens.spaceLg),
            child: BudgetChart(
              labels: ['Presupuesto', 'Gastado', 'Disponible'],
              budgetValues: [
                project.budget,
                project.spent,
                project.budget - project.spent,
              ],
              spentValues: [
                project.budget,
                project.spent,
                project.budget - project.spent,
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceXl),
          const Text(
            'Informes del Proyecto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimens.spaceMd),
          if (reports.isEmpty)
            const EmptyState(icon: Icons.assessment, title: 'Sin informes')
          else
            Column(
              children: reports.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimens.spaceMd),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(AppDimens.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.summary,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${r.authorName} - ${Helpers.timeAgo(r.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.checklist_rtl,
        title: 'Sin tareas',
        message: 'Aún no se han creado tareas para este proyecto.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceSm),
      itemBuilder: (_, i) {
        return TaskCard(
          task: tasks[i],
          onStatusChanged: (status) async {
            await _taskService.updateTaskStatus(tasks[i].id, status);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildDocumentsTab(List<DocumentModel> documents) {
    if (documents.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_off,
        title: 'Sin documentos',
        message: 'No hay documentos compartidos en este proyecto.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      itemCount: documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceSm),
      itemBuilder: (_, i) {
        return DocumentCard(document: documents[i]);
      },
    );
  }

  Widget _buildObjectivesTab(List<ObjectiveModel> objectives) {
    if (objectives.isEmpty) {
      return const EmptyState(
        icon: Icons.flag_outlined,
        title: 'Sin objetivos',
        message: 'No se han definido objetivos para este proyecto.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.spaceLg),
      itemCount: objectives.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceMd),
      itemBuilder: (_, i) {
        final obj = objectives[i];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag, size: 18, color: _objectiveColor(obj.status)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      obj.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _objectiveColor(obj.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    ),
                    child: Text(
                      obj.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _objectiveColor(obj.status),
                      ),
                    ),
                  ),
                ],
              ),
              if (obj.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  obj.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.spaceMd),
              Row(
                children: [
                  Text(
                    '${obj.completedMilestones}/${obj.milestones.length} hitos',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: AppDimens.spaceSm),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: obj.progress,
                        minHeight: 4,
                        backgroundColor: AppColors.border,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_objectiveColor(obj.status)),
                      ),
                    ),
                  ),
                ],
              ),
              if (obj.milestones.isNotEmpty) ...[
                const SizedBox(height: AppDimens.spaceSm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(obj.milestones.length, (mi) {
                    final completed = mi < obj.completedMilestones;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppDimens.radiusS),
                        border: Border.all(
                          color: completed ? AppColors.success : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            completed ? Icons.check_circle : Icons.circle_outlined,
                            size: 12,
                            color: completed ? AppColors.success : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            obj.milestones[mi],
                            style: TextStyle(
                              fontSize: 11,
                              color: completed ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _objectiveColor(ObjectiveStatus status) {
    switch (status) {
      case ObjectiveStatus.achieved:
        return AppColors.success;
      case ObjectiveStatus.inProgress:
        return AppColors.info;
      case ObjectiveStatus.notStarted:
        return AppColors.textMuted;
      case ObjectiveStatus.deferred:
        return AppColors.warning;
    }
  }
}
