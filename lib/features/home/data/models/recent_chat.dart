/// One recent chat room on the home dashboard.
///
/// A presentation view-model built by the screen from a [HomeChat]: the time of
/// the last message arrives already localized, and both the message text and
/// that time are null when the room sent no last message.
class RecentChat {
  const RecentChat({
    required this.roomName,
    required this.initial,
    this.lastMessage,
    this.lastMessageAt,
  });

  /// The room's own name.
  final String roomName;

  /// A single character for the avatar, already safe to measure.
  final String initial;

  /// The last message's text, or null when the room has none.
  final String? lastMessage;

  /// Localized time/date of the last message; null when there is none or it
  /// could not be read.
  final String? lastMessageAt;
}
