import 'package:flutter/material.dart';
import 'package:tatli_sozluk/profile_part.dart';
import 'package:tatli_sozluk/settings_page.dart';


class AppRoutes {
  static const initialRoute = '/profile';

  static final routes = <String, WidgetBuilder>{
    '/profile': (context) => const ProfilePage(),
    '/settings': (context) => const SettingsPage(),

  };
}