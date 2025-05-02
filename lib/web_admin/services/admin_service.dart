import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matefit_frontend/models/user_model.dart';

class AdminService {
    static const String baseUrl = "http://localhost:8080/api/admin";

    static Future<List<UserModel>> fetchUsers() async {
        final url = Uri.parse("$baseUrl/users");
        final response = await http.get(url);

        if (response.statusCode == 200) {
            final List data = jsonDecode(response.body);
            return data.map((json) => UserModel.fromJson(json)).toList();
        } else {
            throw Exception("Failed to fetch users");
        }
    }

    static Future<UserModel?> searchUserByEmail(String email) async {
        final url = Uri.parse("$baseUrl/users/search?email=$email");
        final response = await http.get(url);

        if (response.statusCode == 200) {
            return UserModel.fromJson(jsonDecode(response.body));
        }
        return null;
    }

    static Future<bool> deleteUser(String email) async {
        final url = Uri.parse("$baseUrl/users?email=$email");
        final response = await http.delete(url);
        return response.statusCode == 200;
    }

    static Future<bool> updateUser(String email, UserModel updatedUser) async {
        final url = Uri.parse("$baseUrl/users?email=$email");
        final response = await http.put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(updatedUser.toJson()),
        );

        return response.statusCode == 200;
    }

    static Future<bool> changeRole(String email, String role) async {
        final url = Uri.parse("$baseUrl/users/role?email=$email&role=$role");
        final response = await http.put(url);
        return response.statusCode == 200;
    }

    static Future<bool> toggleUser(String email, bool enable) async {
        final url = Uri.parse("$baseUrl/users/toggle?email=$email&enable=$enable");
        final response = await http.put(url);
        return response.statusCode == 200;
    }

    static Future<int> getUserCount() async {
        final url = Uri.parse("$baseUrl/stats/users-count");
        final response = await http.get(url);
        if (response.statusCode == 200) {
            return int.parse(response.body.toString());
        }
        return 0;
    }
}
