import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import 'data/models/course_details.dart';

/// Opens the details page of [course] on the router.
///
/// The route lives on the root navigator, so the details page sits above the
/// tab shell and covers the bottom navigation — the same behaviour the screen
/// had when it was pushed with a [MaterialPageRoute]. The page carries its own
/// back affordance, so both the header arrow and the system back gesture return
/// the learner to the list they came from.
Future<void> openCourseDetails(
  BuildContext context,
  CourseDetails course,
) async {
  await context.pushNamed<void>(RouteNames.courseDetails, extra: course);
}
