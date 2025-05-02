import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // 👈 لإتاحة File في الويب
import 'package:http/http.dart' as http;

import '../../models/challenge_model.dart';

class ChallengeService {
  static const String baseUrl = 'http://localhost:8080/api/challenges';


  static Future<List<Challenge>> fetchChallenges() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Challenge.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load challenges");
    }
  }

  static Future<bool> deleteChallenge(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }

  static Future<bool> updateChallenge(Challenge challenge, {html.File? image}) async {
    try {
      final uri = Uri.parse('$baseUrl/${challenge.id}');
      final request = http.MultipartRequest('PUT', uri);

      request.fields['title'] = challenge.title;
      request.fields['description'] = challenge.description;
      request.fields['date'] = challenge.date;
      request.fields['kcal'] = (challenge.kcal ?? 0).toString();
      request.fields['location'] = challenge.location;

      // 👇 رفع الصورة باستخدام fromBytes بدلاً من fromPath
      if (image != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(image);

        final completer = Completer<List<int>>();
        reader.onLoadEnd.listen((event) {
          completer.complete(reader.result as List<int>);
        });

        final bytes = await completer.future;

        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      print('❌ Error while updating challenge: $e');
      return false;
    }
  }
}
