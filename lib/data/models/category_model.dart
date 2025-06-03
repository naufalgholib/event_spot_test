class CategoryModel {
  final int id;
  final String name;
  final String? slug;
  final String description;
  final String icon;
  final bool? isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    required this.description,
    required this.icon,
    this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: json['is_active'] == null
          ? null
          : (json['is_active'].toString().toLowerCase() == 'true' ||
              json['is_active'].toString() == '1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'is_active': isActive,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? icon,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}
