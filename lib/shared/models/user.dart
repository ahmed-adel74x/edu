import 'user_role.dart';

/// The signed-in account.
///
/// Deliberately minimal while auth is mocked: the router only needs [role], and
/// the screens that greet the user only need [name]. The rest of the profile
/// fields land here when the backend and the profile screens do.
class User {
  const User({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final UserRole role;
}
