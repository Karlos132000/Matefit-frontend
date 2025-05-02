import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'nutrition_tip_details_screen.dart';

class NutritionTip {
  final String title;
  final String description;
  final String? imageUrl;

  NutritionTip({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory NutritionTip.fromJson(Map<String, dynamic> json) {
    return NutritionTip(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class NutritionTipsTab extends StatefulWidget {
  const NutritionTipsTab({super.key});

  @override
  State<NutritionTipsTab> createState() => _NutritionTipsTabState();
}

class _NutritionTipsTabState extends State<NutritionTipsTab> {
  late Future<List<NutritionTip>> tipsFuture;

  @override
  void initState() {
    super.initState();
    tipsFuture = fetchNutritionTips();
  }

  Future<List<NutritionTip>> fetchNutritionTips() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.43:8080/api/nutrition/tips'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => NutritionTip.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nutrition tips');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: FutureBuilder<List<NutritionTip>>(
        future: tipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tips found."));
          }

          final tips = snapshot.data!;
          return ListView.builder(
            itemCount: tips.length,
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NutritionTipDetailsScreen(
                        title: tip.title,
                        description: tip.description,
                        imageUrl: tip.imageUrl,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: tip.imageUrl != null
                            ? Image.network(
                          'http://192.168.0.43:8080${tip.imageUrl}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        )
                            : Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(child: Text("No image")),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
