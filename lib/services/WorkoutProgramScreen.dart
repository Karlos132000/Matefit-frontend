import 'package:http/http.dart' as http;
import 'dart:convert';

class DayService {
  final String baseUrl = 'http://10.0.2.2:8080/api/days';

  Future<List<int>> getCompletedDayNumbers() async {
    final response = await http.get(Uri.parse('$baseUrl/completed'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<int>((day) => day['dayNumber'] as int).toList();
    } else {
      throw Exception('Failed to load completed days');
    }
  }
}
