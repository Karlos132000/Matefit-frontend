import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import '../widgets/challenge_card.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greeting = '';
  String userName = 'User';
  List<String> categories = [
    "Full body", "Core", "Arm", "Chest",
    "Butt & Leg", "Back", "Shoulder", "Custom"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _deleteOldChallenges(); // ✅ حذف التحديات المنتهية تلقائياً عند فتح الصفحة
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('username') ?? 'User';
    final dynamicGreeting = _getGreeting();

    setState(() {
      userName = name;
      greeting = dynamicGreeting;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ Good morning';
    if (hour < 17) return '🌤️ Good afternoon';
    if (hour < 20) return '🌇 Good evening';
    return '🌙 Good night';
  }

  IconData _getIconForCategory(int index) {
    switch (index) {
      case 0:
        return Icons.fitness_center;
      case 1:
        return Icons.accessibility_new;
      case 2:
        return Icons.pan_tool_alt;
      case 3:
        return Icons.favorite;
      case 4:
        return Icons.directions_run;
      case 5:
        return Icons.back_hand;
      case 6:
        return Icons.accessibility;
      case 7:
        return Icons.grid_view;
      default:
        return Icons.fitness_center;
    }
  }

  // ✅ حذف التحديات القديمة تلقائيًا عند بداية الصفحة
  Future<void> _deleteOldChallenges() async {
    try {
      await ChallengeService.deleteOldChallenges();
      print('✅ Old challenges deleted automatically.');
    } catch (e) {
      print('❌ Error deleting old challenges: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Greeting Block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting, $userName', style: heading1),
                  const SizedBox(height: 6),
                  Text("Let's get this week going!", style: textBody1),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Categories Section
            Text("Categories", style: heading1),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          _getIconForCategory(index),
                          color: primaryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categories[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: darkNeutralColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            Text("Today's Challenges", style: heading1),
            const SizedBox(height: 16),

            // ✅ FutureBuilder خاص بالتحديات
            FutureBuilder<List<Challenge>>(
              future: ChallengeService.fetchChallenges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("❌ Failed to load challenges"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No challenges found."));
                }

                final challenges = snapshot.data!;
                final todayChallenges = challenges.where((c) {
                  if (c.date != null && c.date.isNotEmpty) {
                    final challengeDate = DateTime.tryParse(c.date);
                    return challengeDate != null &&
                        challengeDate.year == now.year &&
                        challengeDate.month == now.month &&
                        challengeDate.day == now.day;
                  }
                  return false;
                }).toList();

                if (todayChallenges.isEmpty) {
                  return const Center(child: Text("No challenges for today."));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayChallenges.length,
                  itemBuilder: (context, index) {
                    return ChallengeCard(challenge: todayChallenges[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
