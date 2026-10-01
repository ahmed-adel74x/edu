import 'user_role.dart';

class User {
  const User({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final UserRole role;
}
