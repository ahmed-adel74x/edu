/// The three account types the app knows.
enum UserRole {
  student,
  teacher,
  parent;

  /// The role named by the backend, or null for a value this app doesn't know.
  ///
  /// The app only serves students, so an unknown value is a value the caller
  /// must reject rather than guess at.
  static UserRole? fromApi(String? value) {
    final name = value?.trim().toLowerCase();
    for (final role in UserRole.values) {
      if (role.name == name) return role;
    }
    return null;
  }
}

