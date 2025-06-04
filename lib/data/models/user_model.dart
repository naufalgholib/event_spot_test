class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? bio;
  final String userType; // 'admin', 'user', 'promotor'
  final bool isVerified;
  final bool? isActive;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Promotor specific details (populated if userType is 'promotor')
  final PromoterDetailModel? promoterDetail;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
    required this.userType,
    this.isVerified = false,
    this.isActive,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.promoterDetail,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }

    // Parse boolean values safely
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return UserModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      userType: json['user_type'] ?? 'user',
      isVerified: parseBool(json['is_verified']),
      isActive: json['is_active'] != null ? parseBool(json['is_active']) : null,
      emailVerifiedAt: parseDate(json['email_verified_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      promoterDetail: json['promoter_detail'] != null
          ? PromoterDetailModel.fromJson(json['promoter_detail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'bio': bio,
      'user_type': userType,
      'is_verified': isVerified ? 1 : 0,
      'is_active': isActive != null
          ? isActive!
              ? 1
              : 0
          : null,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };

    if (promoterDetail != null) {
      data['promoter_detail'] = promoterDetail!.toJson();
    }

    return data;
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? bio,
    String? userType,
    bool? isVerified,
    bool? isActive,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    PromoterDetailModel? promoterDetail,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      userType: userType ?? this.userType,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      promoterDetail: promoterDetail ?? this.promoterDetail,
    );
  }

  bool get isAdmin => userType == 'admin';
  bool get isPromoter => userType == 'promotor';
  bool get isRegularUser => userType == 'user';
}

class PromoterDetailModel {
  final int id;
  final int userId;
  final String? companyName;
  final String? companyLogo;
  final String? description;
  final String? website;
  final Map<String, dynamic>? socialMedia;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final String? verificationDocument;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromoterDetailModel({
    required this.id,
    required this.userId,
    this.companyName,
    this.companyLogo,
    this.description,
    this.website,
    this.socialMedia,
    required this.verificationStatus,
    this.verificationDocument,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromoterDetailModel.fromJson(Map<String, dynamic> json) {
    return PromoterDetailModel(
      id: json['id'],
      userId: json['user_id'],
      companyName: json['company_name'],
      companyLogo: json['company_logo'],
      description: json['description'],
      website: json['website'],
      socialMedia: json['social_media'] != null
          ? json['social_media'] is String
              ? Map<String, dynamic>.from(json['social_media'])
              : json['social_media']
          : null,
      verificationStatus: json['verification_status'],
      verificationDocument: json['verification_document'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_name': companyName,
      'company_logo': companyLogo,
      'description': description,
      'website': website,
      'social_media': socialMedia,
      'verification_status': verificationStatus,
      'verification_document': verificationDocument,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PromoterDetailModel copyWith({
    int? id,
    int? userId,
    String? companyName,
    String? companyLogo,
    String? description,
    String? website,
    Map<String, dynamic>? socialMedia,
    String? verificationStatus,
    String? verificationDocument,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromoterDetailModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      description: description ?? this.description,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocument: verificationDocument ?? this.verificationDocument,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
