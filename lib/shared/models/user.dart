import 'user_role.dart';

/// The signed-in account, as the backend describes it.
///
/// Plain data: [fromJson] never throws on a missing or null key (a field the
/// backend omitted simply stays null / empty), and [toJson] round-trips it for
/// the local cache. No colors or display formatting live here.
///
/// [role] is nullable because an unknown role from the backend must be rejected,
/// not guessed at ([UserRole.fromApi] returns null for it).
class User {
  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.studentId = '',
    this.studentCode = '',
    this.mobile = '',
    this.gender,
    this.address,
    this.image,
    this.cover,
    this.academic = const AcademicInfo(),
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: _string(json['user_id']),
    studentId: _string(json['student_id']),
    studentCode: _string(json['student_code']),
    name: _string(json['name']),
    email: _string(json['email']),
    mobile: _string(json['mobile']),
    role: UserRole.fromApi(_stringOrNull(json['role'])),
    gender: _stringOrNull(json['gender']),
    address: _stringOrNull(json['address']),
    image: _stringOrNull(json['image']),
    cover: _stringOrNull(json['cover']),
    academic: AcademicInfo.fromJson(_mapOrNull(json['academic'])),
  );

  final String userId;
  final String studentId;
  final String studentCode;
  final String name;
  final String email;
  final String mobile;
  final UserRole? role;
  final String? gender;
  final String? address;
  final String? image;
  final String? cover;
  final AcademicInfo academic;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'student_id': studentId,
    'student_code': studentCode,
    'name': name,
    'email': email,
    'mobile': mobile,
    'role': role?.name,
    'gender': gender,
    'address': address,
    'image': image,
    'cover': cover,
    'academic': academic.toJson(),
  };
}

/// The academic placement the login payload carries: system, stage, grade and
/// class. Every field is optional — this shape is only guaranteed from login.
class AcademicInfo {
  const AcademicInfo({this.system, this.stage, this.grade, this.className});

  factory AcademicInfo.fromJson(Map<String, dynamic>? json) => AcademicInfo(
    system: _stringOrNull(json?['system']),
    stage: _stringOrNull(json?['stage']),
    grade: _stringOrNull(json?['grade']),
    className: _stringOrNull(json?['class']),
  );

  final String? system;
  final String? stage;
  final String? grade;
  final String? className;

  Map<String, dynamic> toJson() => {
    'system': system,
    'stage': stage,
    'grade': grade,
    'class': className,
  };
}

String _string(Object? value) => value?.toString() ?? '';

String? _stringOrNull(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

Map<String, dynamic>? _mapOrNull(Object? value) =>
    value is Map ? value.map((key, item) => MapEntry(key.toString(), item)) : null;

