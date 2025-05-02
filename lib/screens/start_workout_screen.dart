import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../services/day_service.dart';

class StartWorkoutScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final int dayIndex;

  const StartWorkoutScreen({
    Key? key,
    required this.exercises,
    required this.dayIndex,
  }) : super(key: key);

  @override
  _StartWorkoutScreenState createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  int currentIndex = 0;
  int remainingSeconds = 0;
  bool isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startExercise();
  }

  void _startExercise() {
    final exercise = widget.exercises[currentIndex];
    final isTime = exercise.type == 'time';
    remainingSeconds = isTime ? (exercise.duration ?? 30) : 0;

    _timer?.cancel();
    if (isTime) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!isPaused) {
          if (remainingSeconds > 1) {
            setState(() {
              remainingSeconds--;
            });
          } else {
            _completeExercise();
          }
        }
      });
    }
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  Future<void> _completeExercise() async {
    _timer?.cancel();

    if (currentIndex < widget.exercises.length - 1) {
      setState(() {
        currentIndex++;
        isPaused = false;
      });
      _startExercise();
    } else {
      await _finishWorkout();
    }
  }

  Future<void> _skipExercise() async {
    _timer?.cancel();

    if (currentIndex < widget.exercises.length - 1) {
      setState(() {
        currentIndex++;
        isPaused = false;
      });
      _startExercise();
    } else {
      await _finishWorkout();
    }
  }

  Future<void> _finishWorkout() async {
    try {
      await DayService().markDayCompleted(widget.dayIndex + 1);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Workout completed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to mark day as completed')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercises[currentIndex];
    final isTime = exercise.type == 'time';
    final repsOrTime = isTime
        ? '${remainingSeconds}s'
        : 'x${exercise.count ?? ''}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Day ${widget.dayIndex + 1} Workout'),
        backgroundColor: const Color(0xFF655CD1),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                exercise.imageUrl,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                exercise.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                repsOrTime,
                style: const TextStyle(fontSize: 40, color: Colors.red),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: isTime ? _togglePause : null,
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(isPaused ? "Resume" : "Pause"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _skipExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      currentIndex == widget.exercises.length - 1 ? 'Finish' : 'Skip',
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
