// user_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatli_sozluk/user_model.dart';

class UserService {
  static const String _usersKey = 'registered_users';
  
  // Save a new user
  static Future<bool> registerUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users JSON string
      String? usersJsonString = prefs.getString(_usersKey);
      List<Map<String, dynamic>> usersList = [];
      
      // If we have existing users, parse them
      if (usersJsonString != null && usersJsonString.isNotEmpty) {
        usersList = List<Map<String, dynamic>>.from(jsonDecode(usersJsonString));
      }
      
      // Check if username or email already exists
      for (var existingUser in usersList) {
        if (existingUser['username'] == user.username || 
            existingUser['email'] == user.email) {
          print('User already exists');
          return false;
        }
      }
      
      // Add new user to the list
      usersList.add(user.toJson());
      
      // Convert back to JSON string
      String updatedUsersJson = jsonEncode(usersList);
      
      // Save back to SharedPreferences
      bool result = await prefs.setString(_usersKey, updatedUsersJson);
      print('User registered: ${user.username}, Save result: $result');
      print('Current users in storage: ${usersList.length}');
      
      return result;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }
  
  // Get all registered users
  static Future<List<User>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? usersJsonString = prefs.getString(_usersKey);
      
      if (usersJsonString == null || usersJsonString.isEmpty) {
        print('No users found in storage');
        return [];
      }
      
      List<dynamic> usersList = jsonDecode(usersJsonString);
      print('Retrieved ${usersList.length} users from storage');
      
      return usersList.map((userMap) => User.fromJson(userMap)).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
  
  // Verify user credentials
  static Future<User?> login(String usernameOrEmail, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? usersJsonString = prefs.getString(_usersKey);
      
      if (usersJsonString == null || usersJsonString.isEmpty) {
        print('No users found for login');
        return null;
      }
      
      List<dynamic> usersList = jsonDecode(usersJsonString);
      print('Checking ${usersList.length} users for login');
      
      for (var userMap in usersList) {
        if ((userMap['username'] == usernameOrEmail || 
             userMap['email'] == usernameOrEmail) && 
            userMap['password'] == password) {
          print('Login successful for: ${userMap['username']}');
          return User.fromJson(userMap);
        }
      }
      
      print('No matching user found for login');
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }
  
  // For debugging - print all users
  static Future<void> printAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(_usersKey);
    print('Raw users JSON in storage: $usersJson');
  }
}
