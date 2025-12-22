import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneIndexService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check if phone number already exists in the index
  Future<bool> isPhoneTaken(String phone) async {
    try {
      final doc = await _db
          .collection('phoneNumbersIndex')
          .doc(phone)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking phone availability: $e');
      // If we can't check, assume it's taken for security
      return true;
    }
  }

  /// Reserve phone number after successful signup
  Future<void> reservePhone(String phone) async {
    try {
      await _db
          .collection('phoneNumbersIndex')
          .doc(phone)
          .set({
        'createdAt': FieldValue.serverTimestamp(),
        'reserved': true,
      });
    } catch (e) {
      print('Error reserving phone number: $e');
      throw e;
    }
  }

  /// Release phone number (for cleanup if needed)
  Future<void> releasePhone(String phone) async {
    try {
      await _db
          .collection('phoneNumbersIndex')
          .doc(phone)
          .delete();
    } catch (e) {
      print('Error releasing phone number: $e');
      throw e;
    }
  }

  /// Get all reserved phone numbers (admin/debugging)
  Future<List<String>> getReservedPhones() async {
    try {
      final querySnapshot = await _db.collection('phoneNumbersIndex').get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting reserved phones: $e');
      return [];
    }
  }
}
