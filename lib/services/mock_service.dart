import '../models/user_profile.dart';
import '../models/service_category.dart';
import '../models/service_request.dart';

class MockService {
  static String? _currentUserId;
  static String? _currentUserType;
  static final Map<String, UserProfile> _profiles = {};
  static final List<ServiceCategory> _categories = [];
  static final List<ServiceRequest> _requests = [];

  static Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeCategories();
  }

  static void _initializeCategories() {
    _categories.addAll([
      ServiceCategory(
        id: '1',
        name: 'Plumbing',
        description: 'Plumbing services',
        icon: 'plumbing',
        createdAt: DateTime.now(),
      ),
      ServiceCategory(
        id: '2',
        name: 'Electrical',
        description: 'Electrical services',
        icon: 'electrical',
        createdAt: DateTime.now(),
      ),
      ServiceCategory(
        id: '3',
        name: 'Carpentry',
        description: 'Carpentry services',
        icon: 'carpentry',
        createdAt: DateTime.now(),
      ),
      ServiceCategory(
        id: '4',
        name: 'Painting',
        description: 'Painting services',
        icon: 'painting',
        createdAt: DateTime.now(),
      ),
      ServiceCategory(
        id: '5',
        name: 'Cleaning',
        description: 'Cleaning services',
        icon: 'cleaning',
        createdAt: DateTime.now(),
      ),
      ServiceCategory(
        id: '6',
        name: 'HVAC',
        description: 'Heating and cooling services',
        icon: 'hvac',
        createdAt: DateTime.now(),
      ),
    ]);

    _requests.addAll([
      ServiceRequest(
        id: 'r1',
        customerId: 'demo-customer',
        categoryId: '1',
        title: 'Fix leaking kitchen faucet',
        description: 'Kitchen faucet has been leaking for 2 days. Need urgent repair.',
        location: '123 Main St, Springfield',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ServiceRequest(
        id: 'r2',
        customerId: 'demo-customer',
        categoryId: '2',
        title: 'Install ceiling fan',
        description: 'Need to install a new ceiling fan in the bedroom.',
        location: '456 Oak Ave, Springfield',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  static Future<MockAuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
    String? phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserId = userId;
    _currentUserType = userType;

    final profile = UserProfile(
      id: userId,
      userType: userType,
      fullName: fullName,
      phone: phone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _profiles[userId] = profile;

    return MockAuthResponse(
      user: MockUser(id: userId, email: email),
    );
  }

  static Future<MockAuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserId = userId;
    _currentUserType = 'customer';

    final profile = UserProfile(
      id: userId,
      userType: 'customer',
      fullName: 'Demo User',
      phone: '555-0123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _profiles[userId] = profile;

    return MockAuthResponse(
      user: MockUser(id: userId, email: email),
    );
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUserId = null;
    _currentUserType = null;
  }

  static MockUser? get currentUser {
    if (_currentUserId == null) return null;
    return MockUser(id: _currentUserId!, email: 'demo@example.com');
  }

  static Future<UserProfile?> getCurrentProfile() async {
    if (_currentUserId == null) return null;
    await Future.delayed(const Duration(milliseconds: 300));
    return _profiles[_currentUserId];
  }

  static Future<UserProfile?> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profiles[userId];
  }

  static Future<void> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<List<ServiceCategory>> getServiceCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _categories;
  }

  static Future<ServiceRequest> createServiceRequest(
      Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final request = ServiceRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      customerId: data['customer_id'] as String,
      categoryId: data['category_id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      location: data['location'] as String,
      status: data['status'] as String? ?? 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _requests.add(request);
    return request;
  }

  static Future<List<ServiceRequest>> getCustomerRequests(
      String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _requests
        .where((r) => r.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<List<ServiceRequest>> getPendingRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _requests
        .where((r) => r.status == 'pending')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<List<ServiceRequest>> getProfessionalRequests(
      String professionalId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _requests
        .where((r) => r.professionalId == professionalId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> updateServiceRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final oldRequest = _requests[index];
      _requests[index] = ServiceRequest(
        id: oldRequest.id,
        customerId: oldRequest.customerId,
        professionalId: updates['professional_id'] as String? ?? oldRequest.professionalId,
        categoryId: oldRequest.categoryId,
        title: updates['title'] as String? ?? oldRequest.title,
        description: oldRequest.description,
        location: oldRequest.location,
        status: updates['status'] as String? ?? oldRequest.status,
        createdAt: oldRequest.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  static Future<void> acceptServiceRequest(
    String requestId,
    String professionalId,
  ) async {
    await updateServiceRequest(requestId, {
      'professional_id': professionalId,
      'status': 'accepted',
    });
  }
}

class MockUser {
  final String id;
  final String email;

  MockUser({required this.id, required this.email});
}

class MockAuthResponse {
  final MockUser? user;

  MockAuthResponse({this.user});
}
