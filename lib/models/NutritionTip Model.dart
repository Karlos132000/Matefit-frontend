class NutritionTip {
  final String title;
  final String description;
  final String? imageUrl; // ← هنا نخليه nullable

  NutritionTip({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory NutritionTip.fromJson(Map<String, dynamic> json) {
    return NutritionTip(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'], // ممكن تكون null عادي
    );
  }
}
