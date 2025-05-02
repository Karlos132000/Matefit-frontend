// models/exercise_model.dart
class Exercise {
  final int id;
  final String name;
  final String type;
  final int? count;
  final int? duration;
  final String imageUrl;
  final bool completed;

  Exercise({
    required this.id,
    required this.name,
    required this.type,
    this.count,
    this.duration,
    required this.imageUrl,
    required this.completed,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      count: json['count'],
      duration: json['duration'],
      imageUrl: json['imageUrl'],
      completed: json['completed'],
    );
  }
}
