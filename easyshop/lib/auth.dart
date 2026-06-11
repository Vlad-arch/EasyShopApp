import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easyshop/utils/location_service.dart';
import 'package:geocoding/geocoding.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(
    {required String email,
     required String password
    }) async{
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(
    {required String email,
     required String password,
     required String name,
     String? address,
    }) async {
    UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    
    if (credential.user != null) {
      // 1. Update display name in Firebase Auth
      await credential.user!.updateDisplayName(name);
      
      // 2. Create Firestore document with user data
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'address': address,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> createShopWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String address,
  }) async {
    UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final String uid = credential.user!.uid;

      // 1. Update display name in Firebase Auth
      await credential.user!.updateDisplayName(name);

      // 2. Geocode the address
      double? lat;
      double? lng;
      try {
        Location? location = await LocationService().getCoordinatesFromAddress(address);
        if (location != null) {
          lat = location.latitude;
          lng = location.longitude;
        }
      } catch (e) {
        debugPrint("Geocoding failed during shop registration: $e");
      }

      // 3. Create Firestore document with user data
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'isShop': true,
        'role': 'shop',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Create shop document
      await _firestore.collection('shops').doc(uid).set({
        'id': uid,
        'name': name,
        'position': address,
        'email': email,
        'lat': lat,
        'lng': lng,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: "google-sign-in-aborted", message: "Autenticazione con Google annullata.");
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    // Ensure the document exists in Firestore
    final docRef = _firestore.collection('users').doc(userCredential.user!.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName ?? "Utente Google",
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    final user = _firebaseAuth.currentUser;
    bool isGoogleUser = false;
    if (user != null) {
      for (final userInfo in user.providerData) {
        if (userInfo.providerId == 'google.com') {
          isGoogleUser = true;
          break;
        }
      }
    }

    await _firebaseAuth.signOut();

    if (isGoogleUser) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      } catch (e) {
        debugPrint("Error signing out from Google: $e");
      }
    }
  }

  Future<void> updateShopProfile({
    required String name,
    required String email,
    String? password,
    String? address,
  }) async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 1. Update Auth Email & DisplayName
    if (email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }
    await user.updateDisplayName(name);

    // 2. Update Auth Password
    if (password != null && password.isNotEmpty) {
      await user.updatePassword(password);
    }

    // 3. Update Firestore 'users'
    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'email': email,
    });

    // 4. Update Firestore 'shops'
    Map<String, dynamic> shopUpdate = {
      'name': name,
      'email': email,
    };

    if (address != null && address.isNotEmpty) {
      shopUpdate['position'] = address;
      // Geocode
      try {
        Location? location = await LocationService().getCoordinatesFromAddress(address);
        if (location != null) {
          shopUpdate['lat'] = location.latitude;
          shopUpdate['lng'] = location.longitude;
        }
      } catch (e) {
        debugPrint("Geocoding failed during profile update: $e");
      }
    }

    await _firestore.collection('shops').doc(user.uid).update(shopUpdate);
  }

  Future<void> changePassword(String newPassword) async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("User not logged in");
    await user.updatePassword(newPassword);
  }
}