import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'package:event_spot/data/models/category_model.dart';
import 'package:event_spot/data/repositories/mock_category_repository.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final MockCategoryRepository _categoryRepository = MockCategoryRepository();
  bool _isLoading = true;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _categoryRepository.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load categories');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(category);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconData(category.icon ?? 'category'),
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (category.description != null)
                        Text(
                          category.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slug: ${category.slug}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showEditCategoryDialog(category),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _showDeleteCategoryDialog(category),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map icon names to IconData (this would be more comprehensive in a real app)
    switch (iconName) {
      case 'music-note':
        return Icons.music_note;
      case 'business':
      case 'briefcase':
        return Icons.business;
      case 'technology':
      case 'laptop':
        return Icons.laptop;
      case 'art':
      case 'palette':
        return Icons.palette;
      case 'sports':
      case 'football':
        return Icons.sports_soccer;
      case 'food':
      case 'utensils':
        return Icons.restaurant;
      case 'education':
      case 'graduation-cap':
        return Icons.school;
      case 'health':
      case 'heart-pulse':
        return Icons.favorite;
      default:
        return Icons.category;
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., music-note, laptop, palette',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addCategory(
                  nameController.text,
                  descriptionController.text,
                  iconController.text,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(CategoryModel category) {
    final TextEditingController nameController =
        TextEditingController(text: category.name);
    final TextEditingController descriptionController =
        TextEditingController(text: category.description ?? '');
    final TextEditingController iconController =
        TextEditingController(text: category.icon ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., music-note, laptop, palette',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _updateCategory(
                  category.id,
                  nameController.text,
                  descriptionController.text,
                  iconController.text,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete the category "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCategory(category.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addCategory(String name, String description, String icon) {
    // In a real app, this would make an API call
    final String slug = name.toLowerCase().replaceAll(' ', '-');
    final newCategory = CategoryModel(
      id: _categories.isNotEmpty
          ? _categories.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1
          : 1,
      name: name,
      slug: slug,
      description:
          description.isNotEmpty ? description : "No description available",
      icon: icon.isNotEmpty ? icon : "category",
    );

    setState(() {
      _categories.add(newCategory);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "${name}" has been added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateCategory(int id, String name, String description, String icon) {
    // In a real app, this would make an API call
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      final category = _categories[index];
      final String slug = name.toLowerCase().replaceAll(' ', '-');
      final updatedCategory = CategoryModel(
        id: id,
        name: name,
        slug: slug,
        description:
            description.isNotEmpty ? description : "No description available",
        icon: icon.isNotEmpty ? icon : "category",
      );

      setState(() {
        _categories[index] = updatedCategory;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "${name}" has been updated'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _deleteCategory(int id) {
    // In a real app, this would make an API call
    final category = _categories.firstWhere((c) => c.id == id);
    setState(() {
      _categories.removeWhere((c) => c.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "${category.name}" has been deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
