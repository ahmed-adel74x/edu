/// Models for `GET /student/home`: one plain class per block of the documented
/// payload.
///
/// Every [HomeSummary.fromJson] is tolerant — a missing or null key never
/// throws — because a block the backend omits simply comes back empty. Numbers
/// documented as `num` are read through [num] (never assumed to be `int`), the
/// cover path and the teacher/course names stay nullable, and the date strings
/// are kept raw next to a tolerant [DateTime] parse.
///
/// No display formatting and no colors live here; the screen turns these into
/// the dashboard's own view-models.
class HomeSummary {
  const HomeSummary({
    this.counts = const HomeCounts(),
    this.recentQuizzes = const [],
    this.upcomingAssignments = const [],
    this.enrolledCourses = const [],
    this.recentChats = const [],
    this.attendanceChart = const [],
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) => HomeSummary(
    counts: HomeCounts.fromJson(_mapOf(json['counts'])),
    recentQuizzes: _listOf(json['recent_quizzes'], HomeQuiz.fromJson),
    upcomingAssignments: _listOf(
      json['upcoming_assignments'],
      HomeAssignment.fromJson,
    ),
    enrolledCourses: _listOf(json['enrolled_courses'], HomeCourse.fromJson),
    recentChats: _listOf(json['recent_chats'], HomeChat.fromJson),
    attendanceChart: _listOf(
      json['attendance_chart'],
      AttendanceMonth.fromJson,
    ),
  );

  /// The four summary figures (registered courses, study hours…).
  final HomeCounts counts;

  /// Recent quiz attempts (max 2 as served). No dashboard section yet.
  final List<HomeQuiz> recentQuizzes;

  /// Upcoming assignments (max 2 as served).
  final List<HomeAssignment> upcomingAssignments;

  /// Enrolled courses to pick up again (max 2 as served).
  final List<HomeCourse> enrolledCourses;

  /// Recent chat rooms (max 2 as served). No dashboard section yet.
  final List<HomeChat> recentChats;

  /// Attendance by month, January to the current month. No dashboard section.
  final List<AttendanceMonth> attendanceChart;
}

/// The four summary figures shown on the dashboard's stat tiles.
class HomeCounts {
  const HomeCounts({
    this.enrolledCourses = 0,
    this.studyHours = 0,
    this.completedCourses = 0,
    this.certificates = 0,
  });

  factory HomeCounts.fromJson(Map<String, dynamic> json) => HomeCounts(
    enrolledCourses: _intOf(json['enrolled_courses']),
    studyHours: _numOf(json['study_hours']),
    completedCourses: _intOf(json['completed_courses']),
    certificates: _intOf(json['certificates']),
  );

  final int enrolledCourses;

  /// Hours studied — a `num`, never assumed whole.
  final num studyHours;

  final int completedCourses;
  final int certificates;
}

/// One recent quiz attempt.
///
/// [attemptId] can repeat across items, so it is never an identity or a list
/// key; the UI keys the list by index instead.
class HomeQuiz {
  const HomeQuiz({
    this.attemptId = 0,
    this.quizTitle = '',
    this.courseName,
    this.scorePercent = 0,
    this.submittedAt = '',
    this.submittedAtAt,
  });

  factory HomeQuiz.fromJson(Map<String, dynamic> json) {
    final submittedAt = _stringOf(json['submitted_at']);
    return HomeQuiz(
      attemptId: _intOf(json['attempt_id']),
      quizTitle: _stringOf(json['quiz_title']),
      courseName: _stringOrNullOf(json['course_name']),
      scorePercent: _numOf(json['score_percent']),
      submittedAt: submittedAt,
      submittedAtAt: _dateOf(submittedAt),
    );
  }

  final int attemptId;
  final String quizTitle;

  /// The course the quiz belongs to, when the backend sent one.
  final String? courseName;

  /// Score in percent — a `num`, never assumed whole.
  final num scorePercent;

  /// The raw timestamp string, kept as a fallback.
  final String submittedAt;

  /// [submittedAt] parsed tolerantly, or null when it could not be read.
  final DateTime? submittedAtAt;
}

/// One upcoming assignment.
class HomeAssignment {
  const HomeAssignment({
    this.homeworkId = 0,
    this.assignmentTitle = '',
    this.lectureTitle = '',
    this.dueDate = '',
    this.dueDateAt,
  });

  factory HomeAssignment.fromJson(Map<String, dynamic> json) {
    final dueDate = _stringOf(json['due_date']);
    return HomeAssignment(
      homeworkId: _intOf(json['homework_id']),
      assignmentTitle: _stringOf(json['assignment_title']),
      lectureTitle: _stringOf(json['lecture_title']),
      dueDate: dueDate,
      dueDateAt: _dateOf(dueDate),
    );
  }

  final int homeworkId;
  final String assignmentTitle;
  final String lectureTitle;

  /// The raw due-date string (its format is undocumented), kept as a fallback.
  final String dueDate;

  /// [dueDate] parsed tolerantly, or null when it could not be read.
  final DateTime? dueDateAt;
}

/// One enrolled course of the "continue learning" block.
class HomeCourse {
  const HomeCourse({
    this.courseId = 0,
    this.title = '',
    this.coverPath,
    this.teacherName,
    this.progressPercentage = 0,
    this.completedLectures = 0,
    this.totalLectures = 0,
    this.remainingLectures = 0,
  });

  factory HomeCourse.fromJson(Map<String, dynamic> json) => HomeCourse(
    courseId: _intOf(json['course_id']),
    title: _stringOf(json['title']),
    coverPath: _stringOrNullOf(json['cover_path']),
    teacherName: _stringOrNullOf(json['teacher_name']),
    progressPercentage: _numOf(json['progress_percentage']),
    completedLectures: _intOf(json['completed_lectures']),
    totalLectures: _intOf(json['total_lectures']),
    remainingLectures: _intOf(json['remaining_lectures']),
  );

  final int courseId;
  final String title;

  /// The cover's own path/URL exactly as sent (format undocumented), or null.
  final String? coverPath;

  /// The teacher's name, when the backend sent one.
  final String? teacherName;

  /// Completion in percent — a `num`, never assumed whole.
  final num progressPercentage;

  final int completedLectures;
  final int totalLectures;
  final int remainingLectures;
}

/// One recent chat room.
///
/// The nested `last_message` rides as nullable fields rather than a class of its
/// own, because no dashboard section reads it.
class HomeChat {
  const HomeChat({
    this.roomId = 0,
    this.roomName = '',
    this.lastMessageText,
    this.lastMessageCreatedAt,
    this.lastMessageCreatedAtAt,
  });

  factory HomeChat.fromJson(Map<String, dynamic> json) {
    final lastMessage = _mapOf(json['last_message']);
    final createdAt = _stringOrNullOf(lastMessage['created_at']);
    return HomeChat(
      roomId: _intOf(json['room_id']),
      roomName: _stringOf(json['room_name']),
      lastMessageText: _stringOrNullOf(lastMessage['text']),
      lastMessageCreatedAt: createdAt,
      lastMessageCreatedAtAt: _dateOf(createdAt),
    );
  }

  final int roomId;
  final String roomName;

  /// The last message's text, when the room carried one.
  final String? lastMessageText;

  /// The last message's raw timestamp, when the room carried one.
  final String? lastMessageCreatedAt;

  /// [lastMessageCreatedAt] parsed tolerantly, or null.
  final DateTime? lastMessageCreatedAtAt;
}

/// One month of the attendance chart.
///
/// The nested `lectures` / `courses` blocks ride as flat fields, because no
/// dashboard section reads them. [monthName] is the server's English label and
/// is never displayed.
class AttendanceMonth {
  const AttendanceMonth({
    this.month = 0,
    this.monthName = '',
    this.lecturesTotal = 0,
    this.lecturesAttended = 0,
    this.lecturesPercentage = 0,
    this.coursesTotal = 0,
    this.coursesAttended = 0,
    this.coursesPercentage = 0,
  });

  factory AttendanceMonth.fromJson(Map<String, dynamic> json) {
    final lectures = _mapOf(json['lectures']);
    final courses = _mapOf(json['courses']);
    return AttendanceMonth(
      month: _intOf(json['month']),
      monthName: _stringOf(json['month_name']),
      lecturesTotal: _intOf(lectures['total']),
      lecturesAttended: _intOf(lectures['attended']),
      lecturesPercentage: _numOf(lectures['percentage']),
      coursesTotal: _intOf(courses['total']),
      coursesAttended: _intOf(courses['attended']),
      coursesPercentage: _numOf(courses['percentage']),
    );
  }

  /// 1 (January) to 12 (December).
  final int month;

  /// The server's English month label. Localize from [month], never show this.
  final String monthName;

  final int lecturesTotal;
  final int lecturesAttended;
  final num lecturesPercentage;

  final int coursesTotal;
  final int coursesAttended;
  final num coursesPercentage;
}

// -----------------------------------------------------------------------------
// Tolerant readers: a missing / null / wrongly-typed key never throws.
// -----------------------------------------------------------------------------

Map<String, dynamic> _mapOf(Object? value) => value is Map
    ? value.map((key, item) => MapEntry(key.toString(), item))
    : const <String, dynamic>{};

List<T> _listOf<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) return const [];
  final items = <T>[];
  for (final item in value) {
    if (item is Map) {
      items.add(fromJson(_mapOf(item)));
    }
  }
  return items;
}

int _intOf(Object? value) => value is num
    ? value.toInt()
    : (num.tryParse(value?.toString() ?? '')?.toInt() ?? 0);

num _numOf(Object? value) =>
    value is num ? value : (num.tryParse(value?.toString() ?? '') ?? 0);

String _stringOf(Object? value) => value?.toString() ?? '';

String? _stringOrNullOf(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

/// `DateTime.tryParse` after the space in `"2026-09-21 21:04:45"` is swapped for
/// a `T`; null for anything unreadable, so a bad value never crashes.
DateTime? _dateOf(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim().replaceFirst(' ', 'T'));
}