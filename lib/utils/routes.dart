import 'package:flutter/material.dart';
import 'package:tatli_sozluk/entry_detail.dart';
import 'package:tatli_sozluk/log_in.dart';
import 'package:tatli_sozluk/main_page.dart';
import 'package:tatli_sozluk/profile_part.dart';
import 'package:tatli_sozluk/settings_page.dart';
import 'package:tatli_sozluk/sign_in.dart';
import 'package:tatli_sozluk/dm.dart';
import 'package:tatli_sozluk/search_page.dart';
import 'package:tatli_sozluk/pages/message_list_page.dart';

class AppRoutes {
  static const initialRoute ='/login';

  static final routes = <String, WidgetBuilder>{
    '/profile': (context) => const ProfilePage(),
    '/settings': (context) => const SettingsPage(),
    '/main_page':(context)=> const MainPage(),
    '/entry_detail':(context)=>const EntryDetailPage(),
    '/login':(context)=>const LoginPage(),
    '/signin': (context) => const SignInScreen(),
    '/dm': (context) => const DmPage(),
    '/search' :(context) => const SearchPage(),
    '/messages': (context) => const MessageListPage(),
  };
}