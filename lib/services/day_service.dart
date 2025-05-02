import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_model.dart';

class DayService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // ✅ جلب التمارين لليوم
  Future<List<Exercise>> fetchExercisesByDay(int dayNumber) async {
    final url = Uri.parse('$baseUrl/days/$dayNumber/exercises');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Exercise(
        id: item['id'],
        name: item['name'],
        type: item['type'],
        count: item['count'],
        duration: item['duration'],
        imageUrl: item['imageUrl'],
        completed: item['completed'],
      )).toList();
    } else {
      throw Exception('❌ Failed to load exercises');
    }
  }

  // ✅ تعليم يوم كمكتمل
  Future<void> markDayCompleted(int dayNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) {
      throw Exception('❌ No email found in preferences');
    }

    final url = Uri.parse('$baseUrl/users/$email/complete-day/$dayNumber');
    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to mark day as complete');
    }
  }

  // ✅ جلب الأيام المكتملة
  Future<List<int>> fetchCompletedDays() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) {
      throw Exception('❌ No email found in preferences');
    }

    final url = Uri.parse('$baseUrl/users/$email/completed-days');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<int>();
    } else {
      throw Exception('❌ Failed to load completed days');
    }
  }
}
