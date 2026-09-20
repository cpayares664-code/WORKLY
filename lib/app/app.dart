import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class ResearchHubApp extends StatelessWidget {
  const ResearchHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Research Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.dashboard,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
