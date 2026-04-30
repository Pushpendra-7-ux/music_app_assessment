/// Immutable data model representing a music artist.
class ArtistModel {
  final String id;
  final String name;
  final String bio;
  final String imageUrl;
  final int monthlyListeners;

  const ArtistModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
    this.monthlyListeners = 0,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String,
      imageUrl: json['image_url'] as String,
      monthlyListeners: json['monthly_listeners'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'image_url': imageUrl,
      'monthly_listeners': monthlyListeners,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ArtistModel(id: $id, name: $name, listeners: $monthlyListeners)';
}
