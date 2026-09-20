import 'package:flutter/material.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../services/project_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/task_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/empty_state.dart';
import '../app_scaffold.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _taskService = TaskService();
  final _projectService = ProjectService();
  TaskStatus? _filterStatus;
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _taskService.refresh();
    await _projectService.refresh();
    if (mounted) setState(() => _loading = false);
  }

  List<TaskModel> get _filteredTasks {
    var tasks = _taskService.getAllTasks();
    if (_filterStatus != null) {
      tasks = tasks.where((t) => t.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((t) {
        return t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppScaffold(
        title: 'Tareas',
        currentIndex: 2,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tasks = _filteredTasks;

    return AppScaffold(
      title: 'Tareas',
      currentIndex: 2,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loading = true);
          await _loadData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        label: 'Total Tareas',
                        value: '${_taskService.totalTasks}',
                        icon: Icons.checklist_rtl,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: MetricCard(
                        label: 'Completadas',
                        value: '${_taskService.completedTasks}',
                        icon: Icons.task_alt,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: MetricCard(
                        label: 'En Progreso',
                        value: '${_taskService.getTasksByStatus(TaskStatus.inProgress).length}',
                        icon: Icons.pending,
                        color: AppColors.info,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: MetricCard(
                        label: 'Vencidas',
                        value: '${_taskService.overdueCount}',
                        icon: Icons.warning_amber,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: AppDimens.spaceXl),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar tareas...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: AppDimens.spaceMd),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todas', null),
                    const SizedBox(width: AppDimens.spaceSm),
                    _buildFilterChip('Por Hacer', TaskStatus.todo),
                    const SizedBox(width: AppDimens.spaceSm),
                    _buildFilterChip('En Progreso', TaskStatus.inProgress),
                    const SizedBox(width: AppDimens.spaceSm),
                    _buildFilterChip('En Revisión', TaskStatus.review),
                    const SizedBox(width: AppDimens.spaceSm),
                    _buildFilterChip('Completadas', TaskStatus.done),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.spaceLg),
              if (tasks.isEmpty)
                const EmptyState(icon: Icons.checklist_rtl, title: 'Sin tareas')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceSm),
                  itemBuilder: (_, i) {
                    final t = tasks[i];
                    final project = _projectService.getProjectById(t.projectId);
                    return Dismissible(
                      key: Key(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppDimens.radiusL),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await _taskService.deleteTask(t.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tarea "${t.title}" eliminada'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      child: TaskCard(
                        task: t,
                        projectTitle: project?.title,
                        onStatusChanged: (status) async {
                          await _taskService.updateTaskStatus(t.id, status);
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskStatus? status) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showCreateTaskDialog() {
    final projects = _projectService.getAllProjects();
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Primero crea un proyecto'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedProjectId = projects.first.id;
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? dueDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Nueva Tarea'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedProjectId,
                        decoration: const InputDecoration(labelText: 'Proyecto'),
                        items: projects
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.title, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedProjectId = v!),
                      ),
                      const SizedBox(height: AppDimens.spaceMd),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator: (v) => Validators.required(v, field: 'El título'),
                      ),
                      const SizedBox(height: AppDimens.spaceMd),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppDimens.spaceMd),
                      DropdownButtonFormField<TaskPriority>(
                        value: selectedPriority,
                        decoration: const InputDecoration(labelText: 'Prioridad'),
                        items: TaskPriority.values
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.label),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedPriority = v!),
                      ),
                      const SizedBox(height: AppDimens.spaceMd),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          dueDate != null
                              ? 'Vence: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                              : 'Sin fecha límite',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined, size: 20),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => dueDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final task = TaskModel(
                      id: 'temp',
                      projectId: selectedProjectId,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      priority: selectedPriority,
                      dueDate: dueDate,
                      createdAt: DateTime.now(),
                    );
                    await _taskService.addTask(task);
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tarea "${task.title}" creada'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
