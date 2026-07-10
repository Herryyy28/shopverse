import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Attempt to initialize Firebase. 
      // On Windows, this may fail if FirebaseOptions are not provided.
      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');
      
      try {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: AndroidDebugProvider(),
          providerApple: AppleDeviceCheckProvider(),
        );
        debugPrint('Firebase App Check initialized');
      } catch (appCheckError) {
        debugPrint('App Check initialization failed: $appCheckError');
      }

      await _setupFCM();
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      // On Windows, if flutterfire configure hasn't been run, this will fail.
      // We catch it so the app can still boot for UI testing.
    } finally {
      _isInitialized = true;
    }
  }

  static Future<void> _setupFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
        
        // Subscribe to a topic for broadcast notifications
        await messaging.subscribeToTopic('all_users');
        
        String? token = await messaging.getToken();
        debugPrint('FCM Token: $token');
      }
    } catch (e) {
      debugPrint('FCM Setup error: $e');
    }
  }

  static Future<void> sendBroadcastNotification(String title, String body) async {
    debugPrint('Sending Broadcast: $title - $body');
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<Map<String, dynamic>> getUserData(String uid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'uid': uid,
      'name': 'Demo User',
      'email': 'user@shopverse.com',
      'role': 'user',
      'walletBalance': 500.0,
    };
  }

  static Future<String> uploadImage(dynamic file) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800';
  }

  static Future<void> saveProduct(Map<String, dynamic> productData) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Product saved to Firestore: ${productData['name']}');
  }

  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [];
  }

  static Stream<DateTime> getFlashSaleEndTime() {
    // In a real app, this would be:
    // return FirebaseFirestore.instance.collection('settings').doc('flash_sale').snapshots().map((doc) => (doc['endTime'] as Timestamp).toDate());
    
    // Mocking real-time sync for demo purposes
    return Stream.value(DateTime.now().add(const Duration(hours: 3, minutes: 15)));
  }
}
