class PromotionDetailModel {
  final String slug;
  final String title;
  final String content;
  final String image;
  final String publishDate;
  final String? author;

  PromotionDetailModel({
    required this.slug,
    required this.title,
    required this.content,
    required this.image,
    required this.publishDate,
    this.author,
  });

  factory PromotionDetailModel.fromJson(Map<String, dynamic> json) {
    return PromotionDetailModel(
      slug: json['slug'],
      title: json['title'],
      content: json['content'],
      image: json['image'],
      publishDate: json['publish_date'],
      author: json['user']?['fullname'],
    );
  }
}
