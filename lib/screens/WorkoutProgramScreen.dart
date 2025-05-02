import 'package:flutter/material.dart';
import '../services/day_service.dart';
import '../models/exercise_model.dart';
import 'WorkoutPlanScreen.dart';

class WorkoutProgramScreen extends StatefulWidget {
  @override
  _WorkoutProgramScreenState createState() => _WorkoutProgramScreenState();
}

class _WorkoutProgramScreenState extends State<WorkoutProgramScreen> {
  List<int> completedDays = [];
  final DayService _dayService = DayService();

  @override
  void initState() {
    super.initState();
    _loadCompletedDays();
  }

  Future<void> _loadCompletedDays() async {
    try {
      completedDays = await _dayService.fetchCompletedDays();
      setState(() {}); // عمل تحديث للواجهة
    } catch (e) {
      print('❌ Error fetching completed days: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> workoutDays = List.generate(30, (index) {
      final dayNumber = index + 1;
      final isRest = dayNumber % 4 == 0;
      return {
        'name': 'Day $dayNumber',
        'type': isRest ? 'rest' : 'exercise',
        'dayIndex': index,
      };
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      body: Column(
        children: [
          // ✅ الهيدر
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Image.asset(
              'assets/images/header.jpg',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          // ✅ Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: completedDays.isEmpty
                        ? 0
                        : completedDays.length / workoutDays.length,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF655CD1),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${completedDays.length} / ${workoutDays.length} days completed',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          // ✅ قائمة الأيام
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 12),
              itemCount: workoutDays.length,
              itemBuilder: (context, index) {
                final day = workoutDays[index];
                final isRest = day['type'] == 'rest';
                final dayNumber = index + 1;
                final isCompleted = completedDays.contains(dayNumber);

                return GestureDetector(
                  onTap: isRest ? null : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutPlanScreen(dayIndex: index),
                      ),
                    );
                    _loadCompletedDays(); // تحديث التقدم بعد العودة
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green[100] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isRest ? Colors.white : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isRest
                                ? Icons.local_dining
                                : isCompleted
                                ? Icons.check_circle
                                : Icons.fitness_center,
                            color: isRest
                                ? Colors.orange
                                : isCompleted
                                ? Colors.green
                                : const Color(0xFF655CD1),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isRest
                                    ? "Rest day"
                                    : isCompleted
                                    ? "Completed"
                                    : "Workout day",
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
