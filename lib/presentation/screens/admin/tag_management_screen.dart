import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'package:event_spot/data/models/event_model.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({Key? key}) : super(key: key);

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  bool _isLoading = false;
  List<EventTag> _tags = [];

  // Mock data for tags
  final List<EventTag> _mockTags = [
    EventTag(
      id: 1,
      name: 'Festival',
      slug: 'festival',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    EventTag(
      id: 2,
      name: 'Concert',
      slug: 'concert',
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      updatedAt: DateTime.now().subtract(const Duration(days: 85)),
    ),
    EventTag(
      id: 3,
      name: 'Technology',
      slug: 'technology',
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
      updatedAt: DateTime.now().subtract(const Duration(days: 80)),
    ),
    EventTag(
      id: 4,
      name: 'Conference',
      slug: 'conference',
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      updatedAt: DateTime.now().subtract(const Duration(days: 75)),
    ),
    EventTag(
      id: 5,
      name: 'Workshop',
      slug: 'workshop',
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
      updatedAt: DateTime.now().subtract(const Duration(days: 70)),
    ),
    EventTag(
      id: 6,
      name: 'Charity',
      slug: 'charity',
      createdAt: DateTime.now().subtract(const Duration(days: 65)),
      updatedAt: DateTime.now().subtract(const Duration(days: 65)),
    ),
    EventTag(
      id: 7,
      name: 'Sports',
      slug: 'sports',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    EventTag(
      id: 8,
      name: 'Food',
      slug: 'food',
      createdAt: DateTime.now().subtract(const Duration(days: 55)),
      updatedAt: DateTime.now().subtract(const Duration(days: 55)),
    ),
    EventTag(
      id: 9,
      name: 'Art',
      slug: 'art',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
      updatedAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
    EventTag(
      id: 10,
      name: 'Networking',
      slug: 'networking',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, this would fetch tags from the server
    setState(() {
      _tags = List.from(_mockTags);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTags,
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _buildTagsList(),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTagDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tags...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          // Filter tags based on search query
          if (value.isEmpty) {
            setState(() {
              _tags = List.from(_mockTags);
            });
          } else {
            setState(() {
              _tags = _mockTags
                  .where((tag) =>
                      tag.name.toLowerCase().contains(value.toLowerCase()) ||
                      tag.slug.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          }
        },
      ),
    );
  }

  Widget _buildTagsList() {
    if (_tags.isEmpty) {
      return const Center(
        child: Text('No tags found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _tags.length,
      itemBuilder: (context, index) {
        final tag = _tags[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.tag, color: AppTheme.primaryColor),
            ),
            title: Text(
              tag.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Slug: ${tag.slug} • Created: ${_formatDate(tag.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditTagDialog(tag),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteTagDialog(tag),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddTagDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addTag(nameController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTagDialog(EventTag tag) {
    final TextEditingController nameController =
        TextEditingController(text: tag.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _updateTag(tag.id, nameController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTagDialog(EventTag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          'Are you sure you want to delete the tag "${tag.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTag(tag.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addTag(String name) {
    // In a real app, this would make an API call
    final String slug = name.toLowerCase().replaceAll(' ', '-');
    final newTag = EventTag(
      id: _mockTags.isNotEmpty
          ? _mockTags.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1
          : 1,
      name: name,
      slug: slug,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _mockTags.add(newTag);
      _tags = List.from(_mockTags);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tag "${name}" has been added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateTag(int id, String name) {
    // In a real app, this would make an API call
    final index = _mockTags.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tag = _mockTags[index];
      final String slug = name.toLowerCase().replaceAll(' ', '-');
      final updatedTag = EventTag(
        id: id,
        name: name,
        slug: slug,
        createdAt: tag.createdAt,
        updatedAt: DateTime.now(),
      );

      setState(() {
        _mockTags[index] = updatedTag;
        _tags = List.from(_mockTags);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag "${name}" has been updated'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _deleteTag(int id) {
    // In a real app, this would make an API call
    final tag = _mockTags.firstWhere((t) => t.id == id);

    setState(() {
      _mockTags.removeWhere((t) => t.id == id);
      _tags = List.from(_mockTags);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tag "${tag.name}" has been deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
