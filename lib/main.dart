import 'dart:io';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/api_client.dart';

void main() {
  HttpOverrides.global = HttpOverridesIgnoreCert();
  runApp(const ResearchHubApp());
}
