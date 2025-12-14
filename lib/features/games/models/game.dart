class Game {
  final String id;
  final String name;
  final String iframe;
  final String image;
  final String? animatedLogo;
  final String? tag;
  final List<String>? screenshots;

  const Game({
    required this.id,
    required this.name,
    required this.iframe,
    required this.image,
    this.animatedLogo,
    this.tag,
    this.screenshots,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      iframe: json['iframe'] as String,
      image: json['image'] as String,
      animatedLogo: json['animatedLogo'] as String?,
      screenshots: (json['screenshots'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iframe': iframe,
      'image': image,
      'animatedLogo': animatedLogo,
      'screenshots': screenshots,
    };
  }
}
