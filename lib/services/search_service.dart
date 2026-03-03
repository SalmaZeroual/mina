import 'api_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class SearchResult {
  final List<SearchUser> people;
  final List<PostModel> posts;
  final List<SearchGroup> groups;
  final List<SearchService> services;

  SearchResult({
    this.people = const [],
    this.posts = const [],
    this.groups = const [],
    this.services = const [],
  });

  bool get isEmpty => people.isEmpty && posts.isEmpty && groups.isEmpty && services.isEmpty;

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    people:   (json['people']   as List? ?? []).map((j) => SearchUser.fromJson(j)).toList(),
    posts:    (json['posts']    as List? ?? []).map((j) => PostModel.fromJson(j)).toList(),
    groups:   (json['groups']   as List? ?? []).map((j) => SearchGroup.fromJson(j)).toList(),
    services: (json['services'] as List? ?? []).map((j) => SearchService.fromJson(j)).toList(),
  );
}

class SearchUser {
  final String id, fullName, title, cell, cellId, initials;
  final String? avatarUrl;
  final bool isFollowing;
  final int followersCount;

  SearchUser({
    required this.id, required this.fullName, required this.title,
    required this.cell, required this.cellId, required this.initials,
    this.avatarUrl, this.isFollowing = false, this.followersCount = 0,
  });

  factory SearchUser.fromJson(Map<String, dynamic> j) => SearchUser(
    id:             j['id']              as String? ?? '',
    fullName:       j['full_name']       as String? ?? '',
    title:          j['title']           as String? ?? '',
    cell:           j['cell']            as String? ?? '',
    cellId:         j['cell_id']         as String? ?? '',
    initials:       j['initials']        as String? ?? '',
    avatarUrl:      j['avatar_url']      as String?,
    isFollowing:    j['is_following']    == true,
    followersCount: j['followers_count'] as int? ?? 0,
  );
}

class SearchGroup {
  final String id, name, description, cell;
  final bool isPrivate, isMember;
  final int membersCount;
  final String? coverUrl;

  SearchGroup({
    required this.id, required this.name, required this.description,
    required this.cell, this.isPrivate = false, this.isMember = false,
    this.membersCount = 0, this.coverUrl,
  });

  factory SearchGroup.fromJson(Map<String, dynamic> j) => SearchGroup(
    id:           j['id']           as String? ?? '',
    name:         j['name']         as String? ?? '',
    description:  j['description']  as String? ?? '',
    cell:         j['cell']         as String? ?? '',
    isPrivate:    j['is_private']   == true,
    isMember:     j['is_member']    == true,
    membersCount: j['members_count'] as int? ?? 0,
    coverUrl:     j['cover_url']    as String?,
  );
}

class SearchService {
  final String id, title, description, cell, priceType;
  final double price, avgRating;
  final int reviewsCount;
  final String? coverUrl;
  final Map<String, dynamic> provider;

  SearchService({
    required this.id, required this.title, required this.description,
    required this.cell, required this.priceType, required this.price,
    this.avgRating = 0, this.reviewsCount = 0, this.coverUrl,
    this.provider = const {},
  });

  factory SearchService.fromJson(Map<String, dynamic> j) => SearchService(
    id:           j['id']            as String? ?? '',
    title:        j['title']         as String? ?? '',
    description:  j['description']   as String? ?? '',
    cell:         j['cell']          as String? ?? '',
    priceType:    j['price_type']    as String? ?? 'fixed',
    price:        (j['price'] as num? ?? 0).toDouble(),
    avgRating:    (j['avg_rating'] as num? ?? 0).toDouble(),
    reviewsCount: j['reviews_count'] as int? ?? 0,
    coverUrl:     j['cover_url']     as String?,
    provider:     j['provider']      as Map<String, dynamic>? ?? {},
  );
}

class SearchService_ {
  static Future<SearchResult> search(String query, {String type = 'all'}) async {
    final data = await ApiService.get(
      '/search?q=${Uri.encodeComponent(query)}&type=$type&limit=30',
    );
    return SearchResult.fromJson(data['data']);
  }

  static Future<bool> toggleFollow(String userId) async {
    final data = await ApiService.post('/search/follow/$userId', {});
    return data['data']['following'] as bool? ?? false;
  }
}