class PromotionModel {
  final String slug;
  final String title;
  final String thumbnail;
  final String image;

  PromotionModel({
    required this.slug,
    required this.title,
    required this.thumbnail,
    required this.image,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      slug: json['slug'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      image: json['image'],
    );
  }
}
