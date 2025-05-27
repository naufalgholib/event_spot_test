import '../../data/models/category_model.dart';

class MockCategoryRepository {
  // Mock list of categories
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: 1,
      name: 'Music',
      description: 'Music concerts and festivals',
      icon: 'music-note',
    ),
    CategoryModel(
      id: 2,
      name: 'Business',
      description: 'Business conferences and networking',
      icon: 'briefcase',
    ),
    CategoryModel(
      id: 3,
      name: 'Technology',
      description: 'Tech meetups and conferences',
      icon: 'laptop',
    ),
    CategoryModel(
      id: 4,
      name: 'Art',
      description: 'Art exhibitions and workshops',
      icon: 'palette',
    ),
    CategoryModel(
      id: 5,
      name: 'Sports',
      description: 'Sports events and tournaments',
      icon: 'football',
    ),
    CategoryModel(
      id: 6,
      name: 'Food',
      description: 'Food festivals and culinary events',
      icon: 'utensils',
    ),
    CategoryModel(
      id: 7,
      name: 'Education',
      description: 'Educational workshops and seminars',
      icon: 'graduation-cap',
    ),
    CategoryModel(
      id: 8,
      name: 'Health',
      description: 'Health and wellness events',
      icon: 'heart-pulse',
    ),
  ];

  // Get all categories
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _categories;
  }

  // Get category by id
  Future<CategoryModel?> getCategoryById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category names
  Future<List<String>> getCategoryNames() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories.map((e) => e.name).toList();
  }

  // Get featured categories (for homepage)
  Future<List<CategoryModel>> getFeaturedCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return first 4 categories as "featured"
    return _categories.take(4).toList();
  }
}
