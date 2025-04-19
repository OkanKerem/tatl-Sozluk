import 'package:flutter/material.dart';
import 'package:tatli_sozluk/log_in.dart';
import 'package:tatli_sozluk/sign_in.dart';
import 'package:tatli_sozluk/main_page.dart';
import 'package:tatli_sozluk/search_page.dart';
import 'package:tatli_sozluk/dm.dart';
import 'package:tatli_sozluk/profile_part.dart';
import 'package:tatli_sozluk/entry_detail.dart';
import 'package:tatli_sozluk/settings_page.dart';
import 'package:tatli_sozluk/pages/popular_entries_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tatlı Sözlük',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignInScreen(),
        '/': (context) => const MainPage(),
        '/search': (context) => const SearchPage(),
        '/dm': (context) => const DMPage(),
        '/profile': (context) => const ProfilePage(),
        '/entry': (context) => const EntryDetailPage(),
        '/settings': (context) => const SettingsPage(),
        '/popular': (context) => const PopularEntriesPage(),
      },
    );
  }
}
