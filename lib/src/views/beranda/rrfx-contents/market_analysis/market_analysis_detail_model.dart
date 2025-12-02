class MarketAnalysisDetailModel {
  final String slug;
  final String title;
  final String content;
  final String image;
  final String publishDate;
  final String authorName;
  final String? authorAvatar;
  final String? authorSpecialist;

  MarketAnalysisDetailModel({
    required this.slug,
    required this.title,
    required this.content,
    required this.image,
    required this.publishDate,
    required this.authorName,
    this.authorAvatar,
    this.authorSpecialist,
  });

  factory MarketAnalysisDetailModel.fromJson(Map<String, dynamic> json) {
    return MarketAnalysisDetailModel(
      slug: json["slug"],
      title: json["title"],
      content: json["content"],
      image: json["image"],
      publishDate: json["publish_date"],
      authorName: json["author"]?["fullname"] ?? "RRFX",
      authorAvatar: json["author"]?["avatar"],
      authorSpecialist: json["author"]?["specialist"],
    );
  }
}
