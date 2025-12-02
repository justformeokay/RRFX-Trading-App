class MarketAnalysisModel {
  final String slug;
  final String title;
  final String thumbnail;
  final String publishDate;
  final String authorName;
  final String category;

  MarketAnalysisModel({
    required this.slug,
    required this.title,
    required this.thumbnail,
    required this.publishDate,
    required this.authorName,
    required this.category,
  });

  factory MarketAnalysisModel.fromJson(Map<String, dynamic> json) {
    return MarketAnalysisModel(
      slug: json['slug'] ?? "",
      title: json['title'] ?? "",
      thumbnail: json['thumbnail'] ?? json['image'] ?? "",
      publishDate: json['publish_date'] ?? "",
      authorName: json['author']?['fullname'] ?? "-",
      category: json['sub_category']?['name'] ?? "",
    );
  }
}
