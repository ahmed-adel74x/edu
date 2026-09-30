/// The three kinds of account the app serves.
///
/// A role decides which bottom-navigation shell and which screens a session
/// gets. Everything that is *not* role-specific — auth, notifications, messages
/// and the shared user / course / assignment components — serves all three.
enum UserRole {
  student,
  teacher,
  parent,
}
