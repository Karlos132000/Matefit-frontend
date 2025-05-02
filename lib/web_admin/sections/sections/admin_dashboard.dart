import 'package:flutter/material.dart';
import 'AdminChallengesTab.dart';
import 'NutritionTipsTab.dart';
import 'admin_users_tab.dart';
import 'exercises_table.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<Widget> _tabs = [
    AdminUsersTab(),
    AdminExercisesTab(),
    AdminChallengesTab(),
    NutritionTipsTab(),
  ];

  final List<String> _titles = [
    "Users",
    "Exercises",
    "Challenges",
    "Nutrition",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🌐 الشريط الجانبي
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFFF5F5FF),
            selectedIconTheme: const IconThemeData(color: Color(0xFF655CD1)),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF655CD1)),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text("Users"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fitness_center),
                label: Text("Exercises"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flag),
                label: Text("Challenges"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fastfood),  // أيقونة النصائح الغذائية
                label: Text("Nutrition"),
              ),
            ],
          ),

          // 📦 محتوى التبويبة المختارة
          Expanded(
            child: Column(
              children: [
                // 🟪 عنوان علوي
                Container(
                  height: 60,
                  color: const Color(0xFF655CD1),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Admin - ${_titles[selectedIndex]}",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // 📋 تبويبة المحتوى
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _tabs[selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
