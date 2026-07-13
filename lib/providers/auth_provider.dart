import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopverse/models/user_model.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:local_auth/local_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopverse/services/secure_storage_service.dart';

class AuthProvider with ChangeNotifier {
  // Use lazy getters to avoid "No Firebase App" crash during provider initialization
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isAuthenticated = false;
  UserModel? _user;
  bool _isAdmin = false;
  String? _verificationId;

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;
  bool get isAdmin => _isAdmin;

  AuthProvider() {
    _tryRestoreSession();
    _initAuthListener();
  }

  Future<void> _tryRestoreSession() async {
    try {
      final cachedUid = await SecureStorageService.read('user_uid');
      final cachedRole = await SecureStorageService.read('user_role');
      if (cachedUid != null && cachedRole != null) {
        _isAuthenticated = true;
        _isAdmin = cachedRole == 'admin';
        _user = UserModel(
          uid: cachedUid,
          name: cachedRole == 'admin'
              ? 'Cached Admin'
              : (cachedRole == 'seller' ? 'Cached Seller' : 'Cached User'),
          email: cachedRole == 'admin'
              ? 'admin@demo.com'
              : (cachedRole == 'seller' ? 'seller@demo.com' : 'demo@demo.com'),
          role: cachedRole,
          createdAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Session restore failed: $e');
    }
  }

  void _initAuthListener() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth.authStateChanges().listen((User? firebaseUser) async {
          if (firebaseUser != null) {
            await _fetchUserData(firebaseUser.uid);
          } else {
            _isAuthenticated = false;
            _user = null;
            _isAdmin = false;
            notifyListeners();
          }
        });
      }
    } catch (e) {
      debugPrint('Auth listener failed to initialize: $e');
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromJson(doc.data()!);
        _isAuthenticated = true;
        _isAdmin = _user!.role == 'admin';
        await SecureStorageService.write('user_uid', _user!.uid);
        await SecureStorageService.write('user_role', _user!.role);
      } else {
        _isAuthenticated = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      if (email == 'demo@demo.com' ||
          email == 'admin@demo.com' ||
          email == 'seller@demo.com') {
        _isAuthenticated = true;
        String role = 'customer';
        if (email == 'admin@demo.com') {
          role = 'admin';
        } else if (email == 'seller@demo.com') {
          role = 'seller';
        }
        _user = UserModel(
          uid: email == 'admin@demo.com'
              ? 'admin_user'
              : (email == 'seller@demo.com' ? 'seller_user' : 'demo_user'),
          name: email == 'admin@demo.com'
              ? 'Demo Admin'
              : (email == 'seller@demo.com' ? 'Demo Seller' : 'Demo User'),
          email: email,
          role: role,
          createdAt: DateTime.now(),
        );
        _isAdmin = email == 'admin@demo.com';
        await SecureStorageService.write('user_uid', _user!.uid);
        await SecureStorageService.write('user_role', _user!.role);
        notifyListeners();
        return null;
      }

      if (Firebase.apps.isEmpty) {
        return "Firebase is not initialized. Please click 'Demo User', 'Demo Seller', or 'Demo Admin' below to log in.";
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithPhone(String phone) async {
    try {
      if (Firebase.apps.isEmpty) {
        return "Phone verification requires Firebase. Please log in using a Demo account.";
      }
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> verifyOtp(String phone, String otp) async {
    if (_verificationId == null) return "Verification ID is missing";

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (!userDoc.exists) {
          _user = UserModel(
            uid: firebaseUser.uid,
            name: 'User ${phone.substring(phone.length - 4)}',
            email: firebaseUser.email ?? '',
            phone: phone,
            role: 'customer',
            createdAt: DateTime.now(),
          );
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(_user!.toJson());
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      if (Firebase.apps.isEmpty) {
        return "Google login requires Firebase. Please log in using a Demo account.";
      }
      if (!kIsWeb && Platform.isWindows) {
        return "Google Sign-In is not supported on Windows Desktop. Please run on Android, iOS, or Chrome Web, or use the Demo Login below.";
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In canceled";

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (!userDoc.exists) {
          _user = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            role: 'customer',
            profileImageUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(),
          );
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(_user!.toJson());
        }
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> linkDevice(String deviceId) async {
    if (_user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('devices')
          .doc(deviceId)
          .set({
            'lastUsed': DateTime.now(),
            'deviceName': 'Mobile Device', // In real app, use device_info_plus
          });
    } catch (e) {
      debugPrint('Error linking device: $e');
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in to ShopVerse',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: !Platform.isWindows && !Platform.isMacOS,
        ),
      );
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      if (Firebase.apps.isEmpty) {
        return "Sign up requires Firebase. Please log in using a Demo account.";
      }
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _user = UserModel(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          role: 'customer',
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(_user!.toJson());
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    if (_user == null) return "User not logged in";

    try {
      _user = _user!.copyWith(
        name: name,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update(_user!.toJson());
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void logout() async {
    try {
      _isAuthenticated = false;
      _user = null;
      _isAdmin = false;
      notifyListeners();

      if (Firebase.apps.isNotEmpty) {
        await _auth.signOut();
      }
      await SecureStorageService.deleteAll();
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }
}
