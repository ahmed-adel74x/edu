class Course {
  const Course({
    required this.image,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.reviews,
    required this.duration,
    required this.price,
    required this.badge,
    required this.avatar,
    required this.category,
    this.buttonLabel = 'اشترك الآن',
  });

  final String image;
  final String title;
  final String instructor;
  final String rating;
  final String reviews;
  final String duration;
  final String price;
  final String badge;
  final String avatar;
  final String category;
  final String buttonLabel;

  static get samples => null;
}
