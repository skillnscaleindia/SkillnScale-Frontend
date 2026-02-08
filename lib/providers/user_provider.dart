import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { customer, pro }

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.customer);
