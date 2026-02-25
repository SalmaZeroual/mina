class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Auth
  static const String login       = '/auth/login';
  static const String register    = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendCode  = '/auth/resend-code';
  static const String logout      = '/auth/logout';
  static const String me          = '/auth/me';

  // Feed
  static String cellFeed(String cellId)    => '/cells/$cellId/feed';
  static const String createPost           = '/posts';
  static String likePost(String postId)    => '/posts/$postId/like';
  static String deletePost(String postId)  => '/posts/$postId';

  // Groups — routes: GET / discover, GET /mine, GET /:id, POST /, POST /:id/join, DELETE /:id/leave
  static const String discoverGroups               = '/groups';
  static const String myGroups                     = '/groups/mine';
  static String groupDetail(String groupId)        => '/groups/$groupId';
  static const String createGroup                  = '/groups';
  static String joinGroup(String groupId)          => '/groups/$groupId/join';
  static String leaveGroup(String groupId)         => '/groups/$groupId/leave';
  static String groupPosts(String groupId)         => '/groups/$groupId/posts';

  // Messages
  static const String conversations                = '/conversations';
  static const String createConversation           = '/conversations';
  static String messages(String conversationId)    => '/conversations/$conversationId/messages';
  static String sendMessage(String conversationId) => '/conversations/$conversationId/messages';

  // Marketplace
  static const String services         = '/marketplace/services';
  static const String myServices        = '/marketplace/services/mine';
  static const String createService     = '/marketplace/services';
  static String deleteService(String serviceId)  => '/marketplace/services/$serviceId';
  static String serviceDetail(String serviceId)  => '/marketplace/services/$serviceId';

  // Profile
  static const String myProfile                    = '/users/me';
  static String userProfile(String userId)         => '/users/$userId';
  static const String updateProfile                = '/users/me';
  static const String updateAvatar                 = '/users/me/avatar';
  static String followUser(String userId)          => '/users/$userId/follow';
  static String unfollowUser(String userId)        => '/users/$userId/follow';

  // Socket
  static const String socketUrl = 'ws://localhost:3000';
}