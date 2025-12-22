import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      throw e;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
    });
  }

  Future<bool> isPhoneTaken(String phone, {String? excludeUid}) async {
    try {
      Query query = _db
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1);

      // If updating existing user, exclude their current record
      if (excludeUid != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeUid);
      }

      final result = await query.get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone availability: $e');
      // If we can't check, assume it's taken for security
      return true;
    }
  }

  Future<void> deleteUserProfile(String uid) {
    try {
      return _db.collection('users').doc(uid).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      throw e;
    }
  }

  // Test Firestore connectivity
  Future<bool> testConnectivity() async {
    try {
      // Try a simple operation to test connection
      // Use a timeout to avoid hanging
      await _db.collection('test').doc('connectivity').get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      return true;
    } catch (e) {
      print('Firestore connectivity test failed: $e');
      return false;
    }
  }

  // Get Firestore settings for debugging
  Map<String, dynamic> getFirestoreSettings() {
    try {
      return {
        'host': _db.app.options.projectId,
        'sslEnabled': true,
        'persistenceEnabled': true,
        'timestampsInSnapshotsEnabled': true,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
