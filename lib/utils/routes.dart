import 'package:flutter/material.dart';
import 'package:tatli_sozluk/entry_detail.dart';
import 'package:tatli_sozluk/log_in.dart';
import 'package:tatli_sozluk/main_page.dart';
import 'package:tatli_sozluk/profile_part.dart';
import 'package:tatli_sozluk/settings_page.dart';
import 'package:tatli_sozluk/sign_in.dart';
import 'package:tatli_sozluk/dm.dart';
import 'package:tatli_sozluk/search_page.dart';
import 'package:tatli_sozluk/pages/popular_entries_page.dart';
import 'package:tatli_sozluk/pages/random_entry_page.dart';
import 'package:tatli_sozluk/pages/other_profile_page.dart';
import 'package:tatli_sozluk/pages/message_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRoutes {
  static const initialRoute ='/login';

  static final routes = <String, WidgetBuilder>{
    '/settings': (context) => const SettingsPage(),
    '/main_page':(context)=> const MainPage(),
    '/login':(context)=>const LoginPage(),
    '/signin': (context) => const SignInScreen(),
    '/messages': (context) => const MessageListPage(),
    '/search' :(context) => const SearchPage(),
    '/popular_entries': (context) => const PopularEntriesPage(),
    '/random_entries': (context) => const RandomEntryPage(),
    // Profile route without parameters - shows current user's profile
    '/profile': (context) => const ProfilePage(),
  };
  
  // Navigate to pages with parameters
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Handle direct message page with receiverId and receiverName
    if (settings.name == '/dm') {
      final args = settings.arguments;
      if (args is Map<String, dynamic> && 
          args.containsKey('receiverId') && 
          args.containsKey('receiverName')) {
        return MaterialPageRoute(
          builder: (context) => DmPage(
            receiverId: args['receiverId'],
            receiverName: args['receiverName'],
          ),
        );
      }
      // If no valid params provided, redirect to message list
      return MaterialPageRoute(
        builder: (context) => const MessageListPage(),
      );
    }
    
    // Handle entry detail page with entryId
    if (settings.name == '/entry_detail') {
      // Check if arguments contain entryId
      final args = settings.arguments;
      if (args is String) {
        return MaterialPageRoute(
          builder: (context) => EntryDetailPage(entryId: args),
        );
      } else if (args is Map<String, dynamic> && args.containsKey('entryId')) {
        return MaterialPageRoute(
          builder: (context) => EntryDetailPage(entryId: args['entryId']),
        );
      }
      // If no valid entryId provided, return error page
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Error: No entry ID provided'),
          ),
        ),
      );
    }
    
    // Handle profile page with userId
    if (settings.name == '/user_profile') {
      // Check if arguments contain userId
      final args = settings.arguments;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      
      // If user is trying to view their own profile, redirect to the regular profile page
      if ((args is String && args == currentUserId) || 
          (args is Map<String, dynamic> && args['userId'] == currentUserId)) {
        return MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        );
      }
      
      // Otherwise, show the other user's profile
      if (args is String) {
        return MaterialPageRoute(
          builder: (context) => OtherProfilePage(userId: args),
        );
      } else if (args is Map<String, dynamic> && args.containsKey('userId')) {
        return MaterialPageRoute(
          builder: (context) => OtherProfilePage(userId: args['userId']),
        );
      }
      
      // If no valid userId provided, return to main profile page
      return MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      );
    }
    
    // For other routes, use the predefined routes
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder);
    }
    
    return null;
  }
}