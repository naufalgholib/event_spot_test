import 'package:flutter/material.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/config/app_router.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_category_repository.dart';
import '../../../data/repositories/mock_event_repository.dart';
import '../../widgets/event_card.dart';

class EventSearchScreen extends StatefulWidget {
  final String? initialQuery;
  final int? categoryId;

  const EventSearchScreen({Key? key, this.initialQuery, this.categoryId})
      : super(key: key);

  @override
  State<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MockEventRepository _eventRepository = MockEventRepository();
  final MockCategoryRepository _categoryRepository = MockCategoryRepository();

  String _searchQuery = '';
  int? _selectedCategoryId;
  String _selectedDateRange = 'all';
  String _selectedPriceRange = 'all';
  String _sortBy = 'date_asc';
  bool _onlyAvailable = false;
  bool _isLoading = false;

  List<EventModel> _searchResults = [];
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery ?? '';
    _selectedCategoryId = widget.categoryId;
    _searchController.text = _searchQuery;
    _loadCategories();
    _performSearch();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepository.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _eventRepository.searchEvents(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _selectedCategoryId,
        dateRange: _selectedDateRange == 'all' ? null : _selectedDateRange,
        priceRange: _selectedPriceRange == 'all' ? null : _selectedPriceRange,
        sortBy: _sortBy,
        onlyAvailable: _onlyAvailable,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_searchQuery.isEmpty ? 'Browse Events' : 'Search Results'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events, categories, locations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _performSearch();
                        },
                      )
                    : null,
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _performSearch();
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyResults()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Filter',
                icon: Icons.filter_list,
                onTap: _showFilterBottomSheet,
              ),
              const SizedBox(width: 8),
              _buildCategorySelector(),
              const SizedBox(width: 8),
              _buildDateSelector(),
              const SizedBox(width: 8),
              _buildPriceSelector(),
              const SizedBox(width: 8),
              _buildSortSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButton<int?>(
      value: _selectedCategoryId,
      hint: const Text('All Categories'),
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (int? value) {
        setState(() {
          _selectedCategoryId = value;
        });
        _performSearch();
      },
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('All Categories'),
        ),
        ..._categories.map((category) {
          return DropdownMenuItem<int?>(
            value: category.id,
            child: Text(category.name),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDateSelector() {
    return DropdownButton<String>(
      value: _selectedDateRange,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedDateRange = value;
          });
          _performSearch();
        }
      },
      items: const [
        DropdownMenuItem<String>(value: 'all', child: Text('Any Time')),
        DropdownMenuItem<String>(value: 'today', child: Text('Today')),
        DropdownMenuItem<String>(value: 'this_week', child: Text('This Week')),
        DropdownMenuItem<String>(
          value: 'this_month',
          child: Text('This Month'),
        ),
      ],
    );
  }

  Widget _buildPriceSelector() {
    return DropdownButton<String>(
      value: _selectedPriceRange,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedPriceRange = value;
          });
          _performSearch();
        }
      },
      items: const [
        DropdownMenuItem<String>(value: 'all', child: Text('Any Price')),
        DropdownMenuItem<String>(value: 'free', child: Text('Free')),
        DropdownMenuItem<String>(value: 'paid', child: Text('Paid')),
      ],
    );
  }

  Widget _buildSortSelector() {
    return DropdownButton<String>(
      value: _sortBy,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _sortBy = value;
          });
          _performSearch();
        }
      },
      items: const [
        DropdownMenuItem<String>(
          value: 'date_asc',
          child: Text('Date (Earliest)'),
        ),
        DropdownMenuItem<String>(
          value: 'date_desc',
          child: Text('Date (Latest)'),
        ),
        DropdownMenuItem<String>(
          value: 'price_asc',
          child: Text('Price (Low to High)'),
        ),
        DropdownMenuItem<String>(
          value: 'price_desc',
          child: Text('Price (High to Low)'),
        ),
        DropdownMenuItem<String>(value: 'popular', child: Text('Most Popular')),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Events',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategoryId = null;
                            _selectedDateRange = 'all';
                            _selectedPriceRange = 'all';
                            _sortBy = 'date_asc';
                            _onlyAvailable = false;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedCategoryId = null;
                            });
                          }
                        },
                      ),
                      ..._categories.map((category) {
                        return FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedCategoryId =
                                  selected ? category.id : null;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Date', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Any Time'),
                        selected: _selectedDateRange == 'all',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedDateRange = 'all';
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Today'),
                        selected: _selectedDateRange == 'today',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedDateRange = 'today';
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('This Week'),
                        selected: _selectedDateRange == 'this_week',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedDateRange = 'this_week';
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('This Month'),
                        selected: _selectedDateRange == 'this_month',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedDateRange = 'this_month';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Price', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Any Price'),
                        selected: _selectedPriceRange == 'all',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedPriceRange = 'all';
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Free'),
                        selected: _selectedPriceRange == 'free',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedPriceRange = 'free';
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Paid'),
                        selected: _selectedPriceRange == 'paid',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              _selectedPriceRange = 'paid';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _onlyAvailable,
                        onChanged: (value) {
                          setModalState(() {
                            _onlyAvailable = value ?? false;
                          });
                        },
                      ),
                      const Text('Show only available events'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performSearch();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final event = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EventCard(
            event: event,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.eventDetail,
                arguments: {'eventId': event.id},
              );
            },
          ),
        );
      },
    );
  }
}
