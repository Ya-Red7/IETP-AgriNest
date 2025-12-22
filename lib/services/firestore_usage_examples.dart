// 📚 Firestore Usage Examples for AgriNest
// This file shows how to use the UserService in different parts of your app

import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

// Example: Get current user profile
Future<Map<String, dynamic>?> getCurrentUserProfile() async {
  final userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      final userDoc = await userService.getUserProfile(user.uid);
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        print('User Name: ${userData['name']}');
        print('User Email: ${userData['email']}');
        print('User Phone: ${userData['phone']}');
        print('Created At: ${userData['createdAt']}');

        // Use the data in your UI
        return userData;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }
  return null;
}

// Example: Update user profile (e.g., from settings)
Future<void> updateUserPhone(String newPhone) async {
  final userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      await userService.updateUserProfile(user.uid, {
        'phone': newPhone,
      });
      print('Phone number updated successfully');
    } catch (e) {
      print('Error updating phone: $e');
    }
  }
}

// Example: Check if user profile exists
Future<bool> userProfileExists() async {
  final userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      final userDoc = await userService.getUserProfile(user.uid);
      return userDoc.exists;
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }
  return false;
}

// Example: Display user info in a widget
/*
Consumer(
  builder: (context, ref, child) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: UserService().getUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return Text('Welcome, ${userData['name']}!');
          }

          return const Text('Welcome!');
        },
      );
    }
    return const Text('Please login');
  },
)
*/
