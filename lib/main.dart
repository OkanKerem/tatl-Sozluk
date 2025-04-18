import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/routes.dart'; // AppRoutes burada tanımlıysa
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // This is essential for using SharedPreferences before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('SharedPreferences initialized');
  
  // Print any existing users for debugging
  String? existingUsers = prefs.getString('registered_users');
  print('Existing users in storage: $existingUsers');
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {   
  const MyApp({super.key});   

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,     
      title: 'Tatlı Sözlük',
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}


