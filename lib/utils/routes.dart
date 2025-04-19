import 'package:flutter/material.dart';
import 'package:tatli_sozluk/profile_part.dart';
import 'package:tatli_sozluk/settings_page.dart';
import 'package:tatli_sozluk/main_page.dart';
import 'package:tatli_sozluk/search_page.dart';
import 'package:tatli_sozluk/dm.dart';


class AppRoutes {
  static const initialRoute = '/';

  static final routes = <String, WidgetBuilder>{
    '/': (context) => const MainPage(),
    '/profile': (context) => const ProfilePage(),
    '/settings': (context) => const SettingsPage(),
    '/search': (context) => const SearchPage(),
    '/dm': (context) => const DMPage(),
  };
}