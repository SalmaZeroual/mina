class ServiceProviderModel {
  final String id;
  final String fullName;
  final String initials;
  final String? avatarUrl;
  final String title;

  ServiceProviderModel({
    required this.id,
    required this.fullName,
    required this.initials,
    this.avatarUrl,
    this.title = '',
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'],
      fullName: json['full_name'],
      initials: json['initials'] ?? '',
      avatarUrl: json['avatar_url'],
      title: json['title'] ?? '',
    );
  }
}

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final ServiceProviderModel provider;
  final double rating;
  final int reviewsCount;
  final String? cell;
  final bool isPublished;
  final bool isOwner;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.provider,
    this.rating = 0,
    this.reviewsCount = 0,
    this.cell,
    this.isPublished = true,
    this.isOwner = false,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      provider: ServiceProviderModel.fromJson(json['provider']),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      cell: json['cell'],
      isPublished: json['is_published'] ?? true,
      isOwner: json['is_owner'] ?? false,
    );
  }
}