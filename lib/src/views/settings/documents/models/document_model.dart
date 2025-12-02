class Document {
  final String name;
  final String link;

  Document({required this.name, required this.link});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      name: json['name'] as String? ?? 'Nama Dokumen Tidak Diketahui',
      link: json['link'] as String? ?? '', // URL PDF
    );
  }
}