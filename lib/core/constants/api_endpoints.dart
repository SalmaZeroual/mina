class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = 'http://10.0.2.2:3000/api/v1';

  // Auth
  static const register = '/auth/register';
  static const login    = '/auth/login';
  static const me       = '/auth/me';

  // Posts
  static const feed     = '/posts/feed';
  static const posts    = '/posts';
  static String like(String id)    => '/posts/$id/like';
  static String comments(String id) => '/posts/$id/comments';

  // Groups
  static const groups         = '/groups';
  static const myGroups       = '/groups/mine';
  static const discoverGroups = '/groups';
  static String joinGroup(String id)  => '/groups/$id/join';
  static String leaveGroup(String id) => '/groups/$id/leave';

  // Messages
  static const conversations            = '/conversations';
  static String convMessages(String id) => '/conversations/$id/messages';

  // Marketplace
  static const services   = '/marketplace/services';
  static const myServices = '/marketplace/services/mine';

  // Users
  static String userProfile(String id) => '/users/$id';
  static String follow(String id)      => '/users/$id/follow';
}