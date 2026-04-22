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
    }) async{
    UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    
    // Create Firestore document with user data
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
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

      // Geocode the address
      double? lat;
      double? lng;
      try {
        Location? location = await LocationService().getCoordinatesFromAddress(address);
        if (location != null) {
          lat = location.latitude;
          lng = location.longitude;
        }
      } catch (e) {
        print("Geocoding failed during shop registration: $e");
      }

      // Create Firestore document with user data
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'isShop': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create shop document
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
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: "google-sign-in-aborted", message: "Autenticazione con Google annullata.");
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    // Salva un nome utente fittizio (fornito dall'account Google) o reale se è la prima registrazione
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName ?? "Utente Google",
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }
}