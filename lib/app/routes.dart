import 'package:flutter/material.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/projects/projects_screen.dart';
import '../screens/projects/create_project_screen.dart';
import '../screens/projects/project_workspace_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/documents/documents_screen.dart';
import '../screens/chat/project_chat_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/reports/progress_reports_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../models/user_model.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String projects = '/projects';
  static const String createProject = '/projects/create';
  static const String projectWorkspace = '/projects/workspace';
  static const String tasks = '/tasks';
  static const String documents = '/documents';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String reports = '/reports';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case dashboard:
        return _fadeRoute(const DashboardScreen());
      case projects:
        return _fadeRoute(const ProjectsScreen());
      case createProject:
        return _fadeRoute(const CreateProjectScreen());
      case projectWorkspace:
        final projectId = args is String ? args : '';
        return _fadeRoute(ProjectWorkspaceScreen(projectId: projectId));
      case tasks:
        return _fadeRoute(const TasksScreen());
      case documents:
        return _fadeRoute(const DocumentsScreen());
      case chat:
        return _fadeRoute(const ProjectChatScreen());
      case notifications:
        return _fadeRoute(const NotificationsScreen());
      case reports:
        return _fadeRoute(const ProgressReportsScreen());
      case analytics:
        return _fadeRoute(AnalyticsScreen());
      case profile:
        return _fadeRoute(const ProfileScreen());
      case editProfile:
        final user = args is UserModel ? args : UserModel(
          id: 'u1',
          name: 'Dra. Elena Vargas',
          email: 'elena.vargas@universidad.edu',
          institution: 'Universidad Nacional de Investigación',
          role: UserRole.principalInvestigator,
          createdAt: DateTime(2020, 3, 15),
        );
        return _fadeRoute(EditProfileScreen(user: user));
      default:
        return _fadeRoute(const DashboardScreen());
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
