import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _currentUserEmailKey = 'current_user_email';
  static const String _usersKey = 'users_data';
  static const String _profileImagesKey = 'profile_images';

  // Initialize dummy users data
  static Future<void> initializeDummyUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData == null) {
      // Create dummy users
      final dummyUsers = [
        {
          'email': 'mahmud.nik@example.com',
          'name': 'Mahmud Nik',
          'password': '123456',
        },
        {
          'email': 'john.doe@example.com',
          'name': 'John Doe',
          'password': 'password123',
        },
        {
          'email': 'jane.smith@example.com',
          'name': 'Jane Smith',
          'password': 'janedoe',
        },
      ];

      await prefs.setString(_usersKey, jsonEncode(dummyUsers));
    }
  }

  // Get all users
  static Future<List<Map<String, String>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData != null) {
      final List<dynamic> usersList = jsonDecode(usersData);
      return usersList.map((user) => Map<String, String>.from(user)).toList();
    }

    return [];
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Check if it's first time using app
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool(_isFirstTimeKey);
    if (isFirstTime == null) {
      // First time launching app
      await prefs.setBool(_isFirstTimeKey, false);
      await initializeDummyUsers(); // Initialize dummy users on first run
      return true;
    }
    return false;
  }

  // Authenticate user
  static Future<Map<String, String>?> authenticate(
      String email,
      String password,
      ) async {
    await initializeDummyUsers(); // Ensure dummy users exist

    final users = await getUsers();

    for (final user in users) {
      if (user['email'] == email && user['password'] == password) {
        return user; // Return user data if authentication successful
      }
    }

    return null; // Authentication failed
  }

  // Register new user
  static Future<bool> registerUser(
      String email,
      String name,
      String password,
      ) async {
    await initializeDummyUsers(); // Ensure dummy users exist

    final users = await getUsers();

    // Check if email already exists
    for (final user in users) {
      if (user['email'] == email) {
        return false; // Email already exists
      }
    }

    // Add new user
    users.add({'email': email, 'name': name, 'password': password});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));

    return true; // Registration successful
  }

  // Set login state
  static Future<void> setLoginState(
      bool isLoggedIn, {
        String? userEmail,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);

    if (userEmail != null) {
      await prefs.setString(_currentUserEmailKey, userEmail);
    }
  }

  // Get current user data
  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString(_currentUserEmailKey);

    if (currentUserEmail != null) {
      final users = await getUsers();
      for (final user in users) {
        if (user['email'] == currentUserEmail) {
          return user;
        }
      }
    }

    return null;
  }

  // Get user email
  static Future<String> getUserEmail() async {
    final currentUser = await getCurrentUser();
    return currentUser?['email'] ?? '';
  }

  // Get user name
  static Future<String> getUserName() async {
    final currentUser = await getCurrentUser();
    return currentUser?['name'] ?? 'User';
  }

  // Get stored profile image path for a user
  static Future<String?> getProfileImagePath(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final imagesData = prefs.getString(_profileImagesKey);
    if (imagesData == null) return null;

    final Map<String, dynamic> imagesMap = jsonDecode(imagesData);
    return imagesMap[email] as String?;
  }

  // Save profile image path for a user
  static Future<void> setProfileImagePath(
      String email,
      String imagePath,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final imagesData = prefs.getString(_profileImagesKey);
    Map<String, dynamic> imagesMap = {};

    if (imagesData != null) {
      imagesMap = jsonDecode(imagesData);
    }

    imagesMap[email] = imagePath;
    await prefs.setString(_profileImagesKey, jsonEncode(imagesMap));
  }

  // Remove stored profile image path for a user (optional helper)
  static Future<void> removeProfileImagePath(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final imagesData = prefs.getString(_profileImagesKey);
    if (imagesData == null) return;

    final Map<String, dynamic> imagesMap = jsonDecode(imagesData);
    imagesMap.remove(email);
    await prefs.setString(_profileImagesKey, jsonEncode(imagesMap));
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserEmailKey);
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}