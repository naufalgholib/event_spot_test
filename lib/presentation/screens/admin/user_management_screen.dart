import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'package:event_spot/data/models/user_model.dart';
import 'package:event_spot/data/services/admin_user_service.dart';

// Define UserType enum for better type safety in our screen
enum UserType { admin, user, promotor }

extension UserTypeStringExt on String {
  UserType toUserType() {
    switch (this) {
      case 'admin':
        return UserType.admin;
      case 'promotor':
        return UserType.promotor;
      case 'user':
      default:
        return UserType.user;
    }
  }
}

extension UserTypeExt on UserType {
  String toStringValue() {
    switch (this) {
      case UserType.admin:
        return 'admin';
      case UserType.promotor:
        return 'promotor';
      case UserType.user:
        return 'user';
    }
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _filterQuery = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  final AdminUserService _userService = AdminUserService();
  List<UserModel> _users = [];

  // Pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  bool _hasMoreUsers = true;
  int _perPage = 20;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUsers(page: 1);

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMoreUsers) {
        _loadMoreUsers();
      }
    }
  }

  Future<void> _fetchUsers({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _users = [];
      });
    }

    try {
      final result =
          await _userService.getUsersPaginated(page: page, perPage: _perPage);
      final List<UserModel> fetchedUsers = result['users'];

      setState(() {
        if (page == 1) {
          _users = fetchedUsers;
        } else {
          _users.addAll(fetchedUsers);
        }
        _currentPage = result['currentPage'];
        _totalPages = result['lastPage'];
        _totalUsers = result['total'];
        _hasMoreUsers = result['hasMore'];
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreUsers) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchUsers(page: _currentPage + 1);
  }

  Future<void> _refreshUsers() async {
    _currentPage = 1;
    await _fetchUsers(page: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  List<UserModel> get _filteredUsers {
    if (_filterQuery.isEmpty) {
      return _users;
    }
    return _users.where((user) {
      return user.name.toLowerCase().contains(_filterQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_filterQuery.toLowerCase());
    }).toList();
  }

  List<UserModel> _getUsersByType(UserType type) {
    return _filteredUsers
        .where((user) => user.userType == type.toStringValue())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Users'),
            Tab(text: 'Promoters'),
          ],
        ),
      ),
      body: _isLoading && _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _users.isEmpty
              ? _buildErrorView()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _filterQuery = value;
                          });
                        },
                      ),
                    ),
                    if (_users.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Showing ${_filteredUsers.length} of $_totalUsers users',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUserList(_filteredUsers),
                          _buildUserList(_getUsersByType(UserType.user)),
                          _buildUserList(_getUsersByType(UserType.promotor)),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add new user
          _showAddUserDialog();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading users',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshUsers,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: users.length + (_hasMoreUsers ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return _buildLoadingIndicator();
          }

          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: user.profilePicture == null
                    ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                        style: const TextStyle(color: AppTheme.primaryColor))
                    : null,
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildUserTypeChip(user.userType.toUserType()),
                      const SizedBox(width: 8),
                      _buildVerificationChip(user.isVerified),
                      if (user.isActive != null) ...[
                        const SizedBox(width: 8),
                        _buildActiveChip(user.isActive!),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleUserAction(value, user),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('View Details'),
                  ),
                  PopupMenuItem(
                    value: 'verify',
                    child: Text(user.isVerified
                        ? 'Revoke Verification'
                        : 'Verify User'),
                  ),
                  if (user.isActive != null)
                    PopupMenuItem(
                      value: 'toggle_active',
                      child: Text(
                          user.isActive! ? 'Deactivate User' : 'Activate User'),
                    ),
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Text('Change Role'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete User'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildUserTypeChip(UserType type) {
    Color chipColor;
    String label;

    switch (type) {
      case UserType.admin:
        chipColor = Colors.red;
        label = 'Admin';
        break;
      case UserType.promotor:
        chipColor = Colors.orange;
        label = 'Promoter';
        break;
      case UserType.user:
      default:
        chipColor = Colors.blue;
        label = 'User';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildVerificationChip(bool isVerified) {
    return Chip(
      label: Text(
        isVerified ? 'Verified' : 'Unverified',
        style: TextStyle(
          color: isVerified ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
      ),
      backgroundColor: isVerified ? Colors.green : Colors.grey[300],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildActiveChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
      ),
      backgroundColor: isActive ? Colors.teal : Colors.grey[300],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  void _handleUserAction(String action, UserModel user) async {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'verify':
        await _toggleUserVerification(user);
        break;
      case 'toggle_active':
        await _toggleUserActiveStatus(user);
        break;
      case 'change_role':
        _showChangeRoleDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showUserDetailsDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profilePicture != null
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: user.profilePicture == null
                      ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                          style: const TextStyle(
                              color: AppTheme.primaryColor, fontSize: 40))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('ID', user.id.toString()),
              _detailRow('Name', user.name),
              _detailRow('Email', user.email),
              _detailRow('Phone', user.phoneNumber ?? 'N/A'),
              _detailRow('User Type', user.userType),
              _detailRow('Verified', user.isVerified ? 'Yes' : 'No'),
              _detailRow(
                  'Status',
                  user.isActive == null
                      ? 'N/A'
                      : (user.isActive! ? 'Active' : 'Inactive')),
              if (user.createdAt != null)
                _detailRow('Created', user.createdAt!.toString()),
              if (user.updatedAt != null)
                _detailRow('Updated', user.updatedAt!.toString()),
              if (user.bio != null && user.bio!.isNotEmpty)
                _detailRow('Bio', user.bio!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserVerification(UserModel user) async {
    try {
      // Toggle the verification status
      final bool newVerificationStatus = !user.isVerified;

      // In a real app, this would make an API call
      // For now, we're just updating the user locally
      final updatedUser = await _userService.updateUser(
        userId: user.id,
        isActive: user.isActive,
        userType: user.userType,
        name: user.name,
        email: user.email,
      );

      // Update the user in the list
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(user.isVerified
              ? 'Verification revoked for ${user.name}'
              : '${user.name} has been verified'),
          backgroundColor: user.isVerified ? Colors.orange : Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleUserActiveStatus(UserModel user) async {
    if (user.isActive == null) return;

    try {
      // Toggle the active status
      final bool newActiveStatus = !user.isActive!;

      // Update the user's active status via API
      final updatedUser =
          await _userService.updateUserActiveStatus(user.id, newActiveStatus);

      // Update the user in the list
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newActiveStatus
              ? '${user.name} has been activated'
              : '${user.name} has been deactivated'),
          backgroundColor: newActiveStatus ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChangeRoleDialog(UserModel user) {
    UserType selectedRole = user.userType.toUserType();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current role: ${user.userType}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserType>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'New Role',
                  border: OutlineInputBorder(),
                ),
                items: UserType.values.map((userType) {
                  return DropdownMenuItem(
                    value: userType,
                    child: Text(userType.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateUserRole(user, selectedRole);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserRole(UserModel user, UserType newRole) async {
    try {
      // Update the user's role via API
      final updatedUser =
          await _userService.updateUserRole(user.id, newRole.toStringValue());

      // Update the user in the list
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${user.name}\'s role updated to ${newRole.toStringValue()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteUser(user);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    try {
      // Delete the user via API
      await _userService.deleteUser(user.id);

      // Remove the user from the list
      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} has been deleted'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    UserType selectedUserType = UserType.user;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserType>(
                  value: selectedUserType,
                  decoration: const InputDecoration(
                    labelText: 'User Type',
                    border: OutlineInputBorder(),
                  ),
                  items: UserType.values.map((userType) {
                    return DropdownMenuItem(
                      value: userType,
                      child: Text(userType.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedUserType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value ?? false;
                        });
                      },
                    ),
                    const Text('Active User'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  await _createUser(
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    phoneNumber: phoneController.text,
                    userType: selectedUserType,
                    isActive: isActive,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required UserType userType,
    required bool isActive,
  }) async {
    try {
      // Create the user via API
      final newUser = await _userService.createUser(
        name: name,
        email: email,
        password: password,
        userType: userType.toStringValue(),
        phoneNumber: phoneNumber,
        isActive: isActive,
      );

      // Add the new user to the list
      setState(() {
        _users.add(newUser);
        _totalUsers++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New user added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
