class Challenge {
  final int? id;
  final String title;
  final String description;
  final String date;
  final int kcal;
  final String location;
  final String? imageUrl;
  final String? creatorEmail;

  Challenge({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.kcal,
    required this.location,
    this.imageUrl,
    this.creatorEmail,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      kcal: json['kcal'] ?? 0,
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'],
      creatorEmail: json['creatorEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'kcal': kcal,
      'location': location,
      'imageUrl': imageUrl,
      'creatorEmail': creatorEmail,
    };
  }
}
