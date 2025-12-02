class PageOneModels {
  final int? id;
  final String name;
  final int age;

  PageOneModels({this.id, required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  factory PageOneModels.fromMap(Map<String, dynamic> map) {
    return PageOneModels(
      id: map['id'],
      name: map['name'],
      age: map['age'],
    );
  }
}