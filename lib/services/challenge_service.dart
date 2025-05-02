import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/challenge_model.dart';

class ChallengeService {
  static const baseUrl = 'http://10.0.2.2:8080/api/challenges';
  static const userBaseUrl = 'http://10.0.2.2:8080/api/users';

  static Future<List<Challenge>> fetchChallenges() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      return data.map((e) => Challenge.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch challenges');
    }
  }

  static Future<bool> deleteChallenge(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    return res.statusCode == 200;
  }

  static Future<bool> joinChallenge(int challengeId, String email) async {
    final res = await http.post(Uri.parse('$userBaseUrl/$email/challenges/$challengeId/join'));
    return res.statusCode == 200;
  }

  static Future<bool> unjoinChallenge(int challengeId, String email) async {
    final res = await http.delete(Uri.parse('$userBaseUrl/$email/challenges/$challengeId/unjoin'));
    return res.statusCode == 204 || res.statusCode == 200;
  }

  static Future<bool> isChallengeJoined(int challengeId, String email) async {
    final res = await http.get(Uri.parse('$userBaseUrl/$email/joined-challenges'));
    if (res.statusCode == 200) {
      List joined = json.decode(res.body);
      return joined.any((ch) => ch['id'] == challengeId);
    }
    return false;
  }

  // ✅ إضافة دالة حذف التحديات القديمة
  static Future<void> deleteOldChallenges() async {
    final url = Uri.parse('$baseUrl/delete-old');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('✅ Old challenges deleted successfully');
      } else {
        print('❌ Failed to delete old challenges: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting old challenges: $e');
    }
  }
}
