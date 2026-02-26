import 'user_model.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final UserModel provider;
  final double rating;
  final int reviewsCount;
  final String cell;
  final bool isPublished;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.provider,
    this.rating = 0,
    this.reviewsCount = 0,
    required this.cell,
    this.isPublished = true,
  });

  static List<ServiceModel> get mocks => [
    ServiceModel(
      id: 's1',
      title: 'React Native Mobile App Development',
      description: 'Professional React Native app development with modern UI/UX',
      price: 2500,
      provider: UserModel(id: 'u2', fullName: 'Sarah Johnson', email: 'sarah@ex.com', initials: 'SJ', cell: 'Web Development', title: 'Flutter Developer', joinedAt: DateTime(2023)),
      rating: 4.9,
      reviewsCount: 127,
      cell: 'Web Development',
    ),
    ServiceModel(
      id: 's2',
      title: 'UI/UX Design for Web Applications',
      description: 'Complete UI/UX design services from wireframes to prototypes',
      price: 1200,
      provider: UserModel(id: 'u4', fullName: 'Emma Wilson', email: 'emma@ex.com', initials: 'EW', cell: 'Design', title: 'UI/UX Designer', joinedAt: DateTime(2023)),
      rating: 5.0,
      reviewsCount: 89,
      cell: 'Design',
    ),
    ServiceModel(
      id: 's3',
      title: 'Backend API Development (Node.js)',
      description: 'Scalable RESTful API development with authentication and documentation',
      price: 1800,
      provider: UserModel(id: 'u5', fullName: 'David Martinez', email: 'david@ex.com', initials: 'DM', cell: 'Web Development', title: 'Backend Developer', joinedAt: DateTime(2023)),
      rating: 4.8,
      reviewsCount: 54,
      cell: 'Web Development',
    ),
    ServiceModel(
      id: 's4',
      title: 'Code Review & Architecture Consulting',
      description: 'Expert code review and software architecture advice for your team',
      price: 500,
      provider: UserModel(id: 'u3', fullName: 'Michael Chen', email: 'michael@ex.com', initials: 'MC', cell: 'Web Development', title: 'React Developer', joinedAt: DateTime(2023)),
      rating: 4.7,
      reviewsCount: 33,
      cell: 'Web Development',
    ),
  ];
}
