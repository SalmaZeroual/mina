import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/select_cell_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/messages/chat_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_detail_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/services/service_detail_screen.dart';
import '../screens/services/publish_service_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/home/create_post_screen.dart';
import '../models/message_model.dart';
import '../models/group_model.dart';
import '../models/service_model.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String selectCell = '/select-cell';
  static const String home = '/home';
  static const String messages = '/messages';
  static const String chat = '/chat';
  static const String groups = '/groups';
  static const String groupDetail = '/group-detail';
  static const String services = '/services';
  static const String serviceDetail = '/service-detail';
  static const String publishService = '/publish-service';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String createPost = '/create-post';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _route(const LoginScreen());
      case register:
        return _route(const RegisterScreen());
      case selectCell:
        return _route(const SelectCellScreen());
      case home:
        return _route(const HomeScreen());
      case messages:
        return _route(const MessagesScreen());
      case chat:
        final conv = settings.arguments as ConversationModel;
        return _route(ChatScreen(conversation: conv));
      case groups:
        return _route(const GroupsScreen());
      case groupDetail:
        final group = settings.arguments as GroupModel;
        return _route(GroupDetailScreen(group: group));
      case services:
        return _route(const ServicesScreen());
      case serviceDetail:
        final service = settings.arguments as ServiceModel;
        return _route(ServiceDetailScreen(service: service));
      case publishService:
        return _route(const PublishServiceScreen());
      case profile:
        return _route(const ProfileScreen());
      case editProfile:
        return _route(const EditProfileScreen());
      case createPost:
        return _route(const CreatePostScreen());
      default:
        return _route(const LoginScreen());
    }
  }

  static PageRouteBuilder _route(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
