import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/NutritionTip Model.dart';

Future<List<NutritionTip>> fetchNutritionTips() async {
  final response = await http.get(Uri.parse('http://192.168.0.43:8080/api/nutrition/tips'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => NutritionTip.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load nutrition tips');
  }
}
