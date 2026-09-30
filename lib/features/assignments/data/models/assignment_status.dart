/// Where an assignment stands in the learner's workflow.
///
/// [submitted] covers work that has been handed in and is being reviewed, which
/// is why its card pill reads "قيد المراجعة" while the filter bar labels the
/// same bucket "تم التسليم" — matching the copy of each spot in the design.
enum AssignmentStatus { pending, submitted, graded }
