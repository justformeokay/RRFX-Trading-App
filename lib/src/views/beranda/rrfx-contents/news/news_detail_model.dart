class NewsDetailModel {
  final String slug;
  final String title;
  final String content;
  final String image;
  final String publishDate;
  final String author;

  NewsDetailModel({
    required this.slug,
    required this.title,
    required this.content,
    required this.image,
    required this.publishDate,
    required this.author,
  });

  factory NewsDetailModel.fromJson(Map<String, dynamic> json) {
    return NewsDetailModel(
      slug: json["slug"],
      title: json["title"],
      content: json["content"],
      image: json["image"],
      publishDate: json["publish_date"],
      author: json["user"]?["fullname"] ?? "Unknown Author",
    );
  }
}
