class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? icon,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}
