import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'package:event_spot/data/models/user_model.dart';

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

  // Mock user data
  final List<UserModel> _users = [
    UserModel(
      id: 1,
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      userType: 'user',
      isVerified: true,
      profilePicture: 'https://i.pravatar.cc/150?img=1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 2,
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      phoneNumber: '+0987654321',
      userType: 'user',
      isVerified: false,
      profilePicture: 'https://i.pravatar.cc/150?img=5',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 3,
      name: 'Bob Johnson',
      email: 'bob.johnson@example.com',
      phoneNumber: '+1122334455',
      userType: 'promotor',
      isVerified: true,
      profilePicture: 'https://i.pravatar.cc/150?img=3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 4,
      name: 'Alice Brown',
      email: 'alice.brown@example.com',
      phoneNumber: '+5544332211',
      userType: 'promotor',
      isVerified: false,
      profilePicture: 'https://i.pravatar.cc/150?img=4',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 5,
      name: 'Charlie Green',
      email: 'charlie.green@example.com',
      phoneNumber: '+6677889900',
      userType: 'admin',
      isVerified: true,
      profilePicture: 'https://i.pravatar.cc/150?img=7',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Regular Users'),
            Tab(text: 'Promoters'),
          ],
        ),
      ),
      body: Column(
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _filterQuery = value;
                });
              },
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
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
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
                  ? Text(user.name[0],
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
                  child: Text(
                      user.isVerified ? 'Revoke Verification' : 'Verify User'),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Text('Block User'),
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

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'verify':
        _toggleUserVerification(user);
        break;
      case 'block':
        _showBlockUserDialog(user);
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
                      ? Text(user.name[0],
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

  void _toggleUserVerification(UserModel user) {
    setState(() {
      // In a real app, this would make an API call
      // For now, we're just toggling the state locally
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user.copyWith(isVerified: !user.isVerified);
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
  }

  void _showBlockUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Mock implementation of blocking a user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been blocked'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Block'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
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
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    UserType selectedUserType = UserType.user;
    bool isVerified = false;

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
                      value: isVerified,
                      onChanged: (value) {
                        setState(() {
                          isVerified = value ?? false;
                        });
                      },
                    ),
                    const Text('Verified User'),
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
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  final newUser = UserModel(
                    id: _users.isNotEmpty
                        ? _users
                                .map((u) => u.id)
                                .reduce((a, b) => a > b ? a : b) +
                            1
                        : 1,
                    name: nameController.text,
                    email: emailController.text,
                    phoneNumber: phoneController.text,
                    userType: selectedUserType.toStringValue(),
                    isVerified: isVerified,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  setState(() {
                    _users.add(newUser);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New user added successfully'),
                      backgroundColor: Colors.green,
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
}
