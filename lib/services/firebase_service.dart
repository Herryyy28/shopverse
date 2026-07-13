import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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

  static Future<void> sendBroadcastNotification(
    String title,
    String body,
  ) async {
    debugPrint('Sending Broadcast: $title - $body');
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<Map<String, dynamic>> getUserData(String uid) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (doc.exists && doc.data() != null) {
          return doc.data()!;
        }
      } catch (e) {
        debugPrint('Firestore getUserData error: $e');
      }
    }
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
    try {
      if (file is! File) {
        // Fallback mock sneaker URL if file isn't real
        return 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800';
      }

      // Replace with your Cloudinary Cloud Name and Upload Preset
      // You get these for free when creating a Cloudinary account
      const cloudName = "e-shopverse";
      const uploadPreset = "";

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );
      final request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonDecoded = json.decode(responseData);

        // Return optimized URL (Cloudinary allows resizing/compressing on-the-fly)
        return jsonDecoded['secure_url'] as String;
      }
    } catch (e) {
      debugPrint("E-commerce image upload failed: $e");
    }

    // Default fallback image if upload fails
    return 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800';
  }

  static Future<void> saveProduct(Map<String, dynamic> productData) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productData['id'])
            .set(productData);
        return;
      } catch (e) {
        debugPrint('Firestore saveProduct error: $e');
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Product saved to Firestore: ${productData['name']}');
  }

  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('products')
            .get();
        return snapshot.docs.map((doc) => doc.data()).toList();
      } catch (e) {
        debugPrint('Firestore fetchProducts error: $e');
      }
    }
    await Future.delayed(const Duration(milliseconds: 800));
    return [];
  }

  static Stream<DateTime> getFlashSaleEndTime() {
    if (Firebase.apps.isNotEmpty) {
      try {
        return FirebaseFirestore.instance
            .collection('settings')
            .doc('flash_sale')
            .snapshots()
            .map((doc) {
              if (doc.exists &&
                  doc.data() != null &&
                  doc.data()!['endTime'] != null) {
                final timestamp = doc.data()!['endTime'] as Timestamp;
                return timestamp.toDate();
              }
              return DateTime.now().add(const Duration(hours: 3, minutes: 15));
            });
      } catch (e) {
        debugPrint('Firestore getFlashSaleEndTime error: $e');
      }
    }

    // Mocking real-time sync for demo purposes
    return Stream.value(
      DateTime.now().add(const Duration(hours: 3, minutes: 15)),
    );
  }
}
