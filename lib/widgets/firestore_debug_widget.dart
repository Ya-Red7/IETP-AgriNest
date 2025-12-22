import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';

class FirestoreDebugWidget extends StatefulWidget {
  const FirestoreDebugWidget({super.key});

  @override
  State<FirestoreDebugWidget> createState() => _FirestoreDebugWidgetState();
}

class _FirestoreDebugWidgetState extends State<FirestoreDebugWidget> {
  final UserService _userService = UserService();
  bool _isConnected = false;
  String _connectionStatus = 'Testing...';
  String _debugInfo = '';
  Map<String, dynamic> _firestoreSettings = {};

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      setState(() {
        _connectionStatus = 'Testing Firestore connection...';
      });

      final connected = await _userService.testConnectivity();
      final settings = _userService.getFirestoreSettings();

      setState(() {
        _isConnected = connected;
        _connectionStatus = connected ? '✅ Connected' : '❌ Connection Failed';
        _firestoreSettings = settings;
      });

      // Gather comprehensive debug info
      final user = FirebaseAuth.instance.currentUser;
      final firebaseApp = Firebase.app();
      final debugInfo = '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FIRESTORE DEBUG INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔐 Authentication:
  User: ${user?.email ?? 'Not logged in'}
  UID: ${user?.uid ?? 'N/A'}
  Authenticated: ${user != null ? '✅ Yes' : '❌ No'}

🔥 Firebase Configuration:
  Project ID: ${firebaseApp.options.projectId}
  App ID: ${firebaseApp.options.appId}
  API Key: ${firebaseApp.options.apiKey.substring(0, 20)}...

📡 Firestore Connection:
  Status: ${connected ? '✅ Connected' : '❌ Failed'}
  Platform: ${Theme.of(context).platform}

⚙️  Firestore Settings:
${settings.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      ''';

      setState(() {
        _debugInfo = debugInfo;
      });

    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = '❌ Error: $e';
        _debugInfo = '''
Error Details: $e

This usually means:
1. Firestore is not enabled in Firebase Console
2. Security rules are blocking access
3. Network connectivity issues
4. Firebase project configuration problems
        ''';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Firestore Debug Info'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _connectionStatus,
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Debug Information:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _debugInfo,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (!_isConnected) ...[
              const Text(
                '🚨 Troubleshooting Steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. 🔥 Enable Firestore in Firebase Console:\n'
                '   • Go to Firebase Console → Firestore Database\n'
                '   • Click "Create database"\n'
                '   • Choose "Start in test mode" (for development)\n\n'
                '2. 🔒 Update Firestore Security Rules:\n'
                '   • Copy rules from firestore-rules.txt\n'
                '   • Go to Firebase Console → Firestore → Rules\n'
                '   • Replace existing rules and Publish\n\n'
                '3. 📱 Check Platform Configuration:\n'
                '   • Web: Add domain to Firebase Console\n'
                '   • Mobile: Check google-services.json/plist\n\n'
                '4. 🌐 Network Connectivity:\n'
                '   • Check internet connection\n'
                '   • Try different network\n\n'
                '5. 🔄 Restart Application:\n'
                '   • Close and reopen the app\n'
                '   • Clear app data/cache if needed',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _testConnection,
          child: const Text('Test Again'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
