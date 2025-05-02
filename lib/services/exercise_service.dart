// services/exercise_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise_model.dart';

class ExerciseService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/days';

  static Future<List<Exercise>> fetchExercisesByDay(int dayNumber) async {
    final url = Uri.parse('$baseUrl/$dayNumber/exercises');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Exercise.fromJson(e)).toList();
    } else {
      throw Exception('❌ Failed to load exercises for day $dayNumber');
    }
  }
}
