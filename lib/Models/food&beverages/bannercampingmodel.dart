class Campaign {
  final String id;
  final String title;
  final String? image;
  final String? displayPosition;
  final String? medium;

  Campaign({
    required this.id,
    required this.title,
    this.image,
    this.displayPosition,
    this.medium,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      image: json['image'],
      displayPosition: json['displayPosition'],
      medium: json['medium'],
    );
  }
}