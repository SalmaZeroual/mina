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

class ReviewerModel {
  final String id;
  final String fullName;
  final String initials;
  final String? avatarUrl;

  ReviewerModel({required this.id, required this.fullName, required this.initials, this.avatarUrl});

  factory ReviewerModel.fromJson(Map<String, dynamic> json) {
    final name = json['full_name'] ?? '';
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return ReviewerModel(
      id: json['id'] ?? '',
      fullName: name,
      initials: json['initials'] ?? initials,
      avatarUrl: json['avatar_url'],
    );
  }
}

class ServiceReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final ReviewerModel reviewer;
  final DateTime createdAt;

  ServiceReviewModel({
    required this.id, required this.rating, this.comment,
    required this.reviewer, required this.createdAt,
  });

  factory ServiceReviewModel.fromJson(Map<String, dynamic> json) {
    return ServiceReviewModel(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      reviewer: ReviewerModel.fromJson(json['reviewer']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}