import 'package:flutter/material.dart';
import '../services/day_service.dart';
import '../models/exercise_model.dart';
import 'start_workout_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  final int dayIndex;

  const WorkoutPlanScreen({Key? key, required this.dayIndex}) : super(key: key);

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  late Future<List<Exercise>> _exercisesFuture;
  final DayService _dayService = DayService();

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _dayService.fetchExercisesByDay(widget.dayIndex + 1); // dayNumber = index + 1
  }

  @override
  Widget build(BuildContext context) {
    final isRestDay = (widget.dayIndex + 1) % 4 == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF655CD1),
        title: Text('Day ${widget.dayIndex + 1} Exercises'),
      ),
      body: isRestDay
          ? const Center(
        child: Text(
          'Rest Day 🧘‍♂️',
          style: TextStyle(fontSize: 20),
        ),
      )
          : FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('❌ Failed to load exercises'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exercises found.'));
          }

          final exercises = snapshot.data!;

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isTime = exercise.type == 'time';
              final repsOrDuration = isTime
                  ? '${exercise.duration ?? 0} sec'
                  : 'x${exercise.count ?? 0}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      exercise.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(repsOrDuration),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: isRestDay
          ? null
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF655CD1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            final exercises = await _exercisesFuture;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StartWorkoutScreen(
                  exercises: exercises,
                  dayIndex: widget.dayIndex,
                ),
              ),
            );
          },
          child: const Text("Start", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
