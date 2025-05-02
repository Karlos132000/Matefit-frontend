import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:matefit_frontend/web_admin/sections/sections/admin_dashboard.dart';
import 'app.dart'; // ملف التطبيق الأساسي Mobile

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: kIsWeb ? const AdminDashboard() : const MyApp(),
    ),
  );
}
