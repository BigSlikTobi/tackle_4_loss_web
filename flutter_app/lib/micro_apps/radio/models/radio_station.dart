class RadioStation {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String>? slideshowImages;
  final String categoryId;
  final String? streamUrl;

  const RadioStation({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.slideshowImages,
    required this.categoryId,
    this.streamUrl,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      slideshowImages: (json['slideshowImages'] as List<dynamic>?)?.map((e) => e as String).toList(),
      categoryId: json['categoryId'] as String,
      streamUrl: json['streamUrl'] as String?,
    );
  }
}
