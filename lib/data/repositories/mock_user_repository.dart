import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';

class MockUserRepository {
  // Mock current user
  UserModel? _currentUser;

  // Mock users with passwords
  final List<Map<String, dynamic>> _usersWithAuth = [
    {
      'user': UserModel(
        id: 1,
        name: 'John Doe',
        email: 'admin@eventspot.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/1.jpg',
        userType: 'admin',
        phoneNumber: '+1234567890',
        bio: 'Platform administrator and event enthusiast.',
        isVerified: true,
        isActive: true,
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 370)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      'password': 'admin123',
    },
    {
      'user': UserModel(
        id: 2,
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/1.jpg',
        userType: 'promotor',
        phoneNumber: '+0987654321',
        bio: 'Event promoter specializing in music festivals and concerts.',
        isVerified: true,
        isActive: true,
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 300)),
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        promoterDetail: PromoterDetailModel(
          id: 1,
          userId: 2,
          companyName: 'Live Nation',
          companyLogo: 'https://example.com/logos/livenation.png',
          description:
              'Leading event promotion company specializing in music concerts and festivals.',
          website: 'https://www.livenation.com',
          socialMedia: {
            'facebook': 'https://facebook.com/livenation',
            'twitter': 'https://twitter.com/livenation',
            'instagram': 'https://instagram.com/livenation',
          },
          verificationStatus: 'verified',
          verificationDocument: 'documents/verification/2_verification.pdf',
          createdAt: DateTime.now().subtract(const Duration(days: 300)),
          updatedAt: DateTime.now().subtract(const Duration(days: 290)),
        ),
      ),
      'password': 'promoter123',
    },
    {
      'user': UserModel(
        id: 3,
        name: 'Mike Johnson',
        email: 'mike.johnson@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/2.jpg',
        userType: 'user',
        isVerified: false,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      'password': 'user123',
    },
    {
      'user': UserModel(
        id: 4,
        name: 'Sarah Williams',
        email: 'sarah.williams@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/women/2.jpg',
        userType: 'promotor',
        phoneNumber: '+2468101214',
        bio: 'Organizing tech conferences and workshops for 5+ years.',
        isVerified: true,
        isActive: true,
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 250)),
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
        promoterDetail: PromoterDetailModel(
          id: 2,
          userId: 4,
          companyName: 'TechEvents Co',
          companyLogo: 'https://example.com/logos/techevents.png',
          description:
              'Specializing in technology conferences, workshops, and hackathons.',
          website: 'https://www.techevents.co',
          socialMedia: {
            'facebook': 'https://facebook.com/techevents',
            'twitter': 'https://twitter.com/techevents',
            'linkedin': 'https://linkedin.com/company/techevents',
          },
          verificationStatus: 'verified',
          verificationDocument: 'documents/verification/4_verification.pdf',
          createdAt: DateTime.now().subtract(const Duration(days: 250)),
          updatedAt: DateTime.now().subtract(const Duration(days: 240)),
        ),
      ),
      'password': 'promoter456',
    },
    {
      'user': UserModel(
        id: 5,
        name: 'Alex Brown',
        email: 'alex.brown@example.com',
        profilePicture: 'https://randomuser.me/api/portraits/men/3.jpg',
        userType: 'user',
        phoneNumber: '+1357902468',
        isVerified: true,
        isActive: true,
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 85)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 85)),
      ),
      'password': 'user456',
    },
  ];

  // Get all users (without passwords)
  List<UserModel> get _users =>
      _usersWithAuth.map((data) => data['user'] as UserModel).toList();

  // Login with email and password verification
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      // For development convenience, allow any password with length >= 6
      if (password.length >= 6) {
        final userWithAuth = _usersWithAuth.firstWhere(
          (data) => (data['user'] as UserModel).email == email,
          orElse: () => {'user': null, 'password': null},
        );

        if (userWithAuth['user'] != null) {
          final user = userWithAuth['user'] as UserModel;
          _currentUser = user;
          return user;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Register
  Future<UserModel> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final now = DateTime.now();
    final newUser = UserModel(
      id: _users.length + 1,
      name: name,
      email: email,
      userType: 'user',
      isVerified: false,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    _usersWithAuth.add({'user': newUser, 'password': password});

    _currentUser = newUser;
    return newUser;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  // Get user by ID
  Future<UserModel?> getUserById(int id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all promoters
  Future<List<UserModel>> getPromoters() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _users.where((user) => user.userType == 'promotor').toList();
  }

  // Update user profile
  Future<UserModel> updateUserProfile(UserModel updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }
      return updatedUser;
    }
    throw Exception('User not found');
  }

  // Logout
  Future<bool> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    return true;
  }

  // Create promoter profile
  Future<UserModel> becomePromoter(
    int userId, {
    required String bio,
    required String companyName,
    String? companyLogo,
    String? description,
    String? website,
    Map<String, dynamic>? socialMedia,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      final now = DateTime.now();
      final user = _users[index];

      final promoterDetail = PromoterDetailModel(
        id: userId, // Using userId as promoter detail id for simplicity
        userId: userId,
        companyName: companyName,
        companyLogo: companyLogo,
        description: description,
        website: website,
        socialMedia: socialMedia,
        verificationStatus: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      final updatedUser = user.copyWith(
        userType: 'promotor',
        bio: bio,
        isVerified: false, // Needs admin verification
        updatedAt: now,
        promoterDetail: promoterDetail,
      );

      _users[index] = updatedUser;
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }
      return updatedUser;
    }
    throw Exception('User not found');
  }

  // Admin verify promoter
  Future<UserModel> verifyPromoter(int promoterId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _users.indexWhere(
      (user) => user.id == promoterId && user.userType == 'promotor',
    );

    if (index != -1) {
      final user = _users[index];
      final now = DateTime.now();

      final updatedPromoterDetail = user.promoterDetail?.copyWith(
        verificationStatus: 'verified',
        updatedAt: now,
      );

      final updatedUser = user.copyWith(
        isVerified: true,
        emailVerifiedAt: now,
        updatedAt: now,
        promoterDetail: updatedPromoterDetail,
      );

      _users[index] = updatedUser;
      return updatedUser;
    }
    throw Exception('Promoter not found');
  }
}
