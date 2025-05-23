import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tatli_sozluk/utils/routes.dart'; // AppRoutes burada tanımlıysa
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';
import 'package:tatli_sozluk/providers/comment_provider.dart';
import 'package:tatli_sozluk/providers/search_provider.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before any platform interaction
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase with configuration options from environment variables
  // This ensures secure storage of sensitive API keys
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
    ),
  );
  
  // Initialize the app with all required providers
  runApp(
  MultiProvider(
    providers: [
      // User authentication and profile management
      ChangeNotifierProvider(
        create: (context) => UserProvider(),
      ),
      // Entry data management
      ChangeNotifierProvider(
        create: (context) => EntryProvider(),
      ),
      // Comment handling
      ChangeNotifierProvider(
        create: (context) => CommentProvider(),
      ),
      // Search functionality
      ChangeNotifierProvider(
        create: (context) => SearchProvider(),
      ),
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SearchProvider for global access throughout the app
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tatlı Sözlük',
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
