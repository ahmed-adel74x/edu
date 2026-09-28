import 'package:flutter/material.dart';

import '../data/models/course_details.dart';
import 'screens/course_details_screen.dart';

/// Opens the details page of [course] on the app's navigator.
///
/// The project has no named-route table — the shell switches tabs by index and
/// everything else is pushed — so this uses the same plain `MaterialPageRoute`
/// pattern as the rest of the app. The pushed page carries its own back
/// affordance, so both the header arrow and the system back gesture return the
/// learner to the list they came from, leaving the bottom navigation untouched.
Future<void> openCourseDetails(BuildContext context, CourseDetails course) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => CourseDetailsScreen(course: course),
    ),
  );
}
