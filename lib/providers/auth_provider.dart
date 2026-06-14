import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopverse/models/user_model.dart';

import 'package:local_auth/local_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    _initAuthListener();
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
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          _user = UserModel(
            uid: firebaseUser.uid,
            name: 'User ${phone.substring(phone.length - 4)}',
            email: firebaseUser.email ?? '',
            phone: phone,
            role: 'customer',
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(firebaseUser.uid).set(_user!.toJson());
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google Sign-In canceled";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          _user = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            role: 'customer',
            profileImageUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(firebaseUser.uid).set(_user!.toJson());
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
      await _firestore.collection('users').doc(_user!.uid).collection('devices').doc(deviceId).set({
        'lastUsed': DateTime.now(),
        'deviceName': 'Mobile Device', // In real app, use device_info_plus
      });
    } catch (e) {
      debugPrint('Error linking device: $e');
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in to ShopVerse',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _user = UserModel(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          role: 'customer',
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(_user!.toJson());
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProfile({String? name, String? phone, String? profileImageUrl}) async {
    if (_user == null) return "User not logged in";

    try {
      _user = _user!.copyWith(
        name: name,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
      await _firestore.collection('users').doc(_user!.uid).update(_user!.toJson());
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }
}
