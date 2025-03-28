class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int? parentId;
  final String? slug;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.parentId,
    this.slug,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      parentId: json['parent_id'],
      slug: json['slug'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'parent_id': parentId,
      'slug': slug,
      'is_active': isActive,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    int? parentId,
    String? slug,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
    );
  }
}
