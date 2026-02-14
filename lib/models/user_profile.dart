class UserProfile {
  final String id;
  final String userType;
  final String fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? profileImageUrl;
  final String? bio;
  final List<String>? skills;
  final double? hourlyRate;
  final double rating;
  final int totalJobs;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userType,
    required this.fullName,
    this.email,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.bio,
    this.skills,
    this.hourlyRate,
    this.rating = 0,
    this.totalJobs = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userType: json['user_type'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      skills: json['skills'] != null
          ? List<String>.from(json['skills'] as List)
          : null,
      hourlyRate: json['hourly_rate'] != null
          ? (json['hourly_rate'] as num).toDouble()
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalJobs: json['total_jobs'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_type': userType,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'skills': skills,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'total_jobs': totalJobs,
    };
  }

  bool get isCustomer => userType == 'customer';
  bool get isProfessional => userType == 'professional';
}
