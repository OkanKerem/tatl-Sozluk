// user_model.dart
import 'dart:io';

class User {
  String username;
  String email;
  String password;
  String? profilePhotoUrl;
  String? assetImagePath;
  
  // Transient field - not serialized
  File? profilePhoto;

  User({
    required this.username, 
    required this.email,
    required this.password,
    this.profilePhoto,
    this.profilePhotoUrl,
    this.assetImagePath,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'profilePhotoUrl': profilePhotoUrl,
      'assetImagePath': assetImagePath,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      profilePhotoUrl: json['profilePhotoUrl'],
      assetImagePath: json['assetImagePath'],
    );
  }
}
