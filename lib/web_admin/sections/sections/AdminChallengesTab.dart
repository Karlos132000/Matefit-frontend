import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'EditChallengeScreen.dart'; // شاشة التعديل

class AdminChallengesTab extends StatefulWidget {
  const AdminChallengesTab({Key? key}) : super(key: key);

  @override
  _AdminChallengesTabState createState() => _AdminChallengesTabState();
}

class _AdminChallengesTabState extends State<AdminChallengesTab> {
  List<dynamic> challenges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChallenges();
  }

  // جلب التحديات من الـ API
  Future<void> fetchChallenges() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/challenges'),
    );

    if (response.statusCode == 200) {
      setState(() {
        challenges = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // عرض رسالة خطأ في حالة فشل الطلب
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to load challenges"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // حذف تحدي بناءً على ID
  Future<void> deleteChallenge(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/challenges/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        challenges.removeWhere((challenge) => challenge['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Challenge deleted successfully"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to delete challenge"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // الانتقال إلى شاشة تعديل التحدي
  void _navigateToEditChallenge(Map<String, dynamic> challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditChallengeScreen(challenge: challenge),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListTile(
              title: Text(challenge['title']),
              subtitle: Text(challenge['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر تعديل التحدي
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _navigateToEditChallenge(challenge),
                  ),
                  // زر حذف التحدي
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteChallenge(challenge['id']),
                  ),
                ],
              ),
              onTap: () {
                // عند الضغط على التحدي يمكن الانتقال إلى شاشة التعديل
                _navigateToEditChallenge(challenge);
              },
            ),
          );
        },
      ),
    );
  }
}
