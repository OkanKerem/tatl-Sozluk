import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tatli_sozluk/utils/routes.dart'; // AppRoutes burada tanımlıysa

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
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
