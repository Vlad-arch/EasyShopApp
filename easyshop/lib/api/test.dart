import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GooglePlayServicesCheckScreen extends StatefulWidget {
  const GooglePlayServicesCheckScreen({super.key});

  @override
  State<GooglePlayServicesCheckScreen> createState() => _GooglePlayServicesCheckScreenState();
}

class _GooglePlayServicesCheckScreenState extends State<GooglePlayServicesCheckScreen> {
  String _availabilityMessage = 'Checking Google Play Services...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkGooglePlayServicesAvailability();
  }

  Future<void> _checkGooglePlayServicesAvailability() async {
    setState(() {
      _isLoading = true;
      _availabilityMessage = 'Checking Google Play Services...';
    });

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email', // You might need other scopes depending on your app's needs
      ],
    );

    try {
      // The canAccessScopes method implicitly checks for Google Play Services availability.
      // If Play Services is not available or outdated, this will typically return false.
      bool canAccess = await googleSignIn.canAccessScopes(['email', 'https://www.googleapis.com/auth/contacts.readonly']);


      if (canAccess) {
        setState(() {
          _availabilityMessage = 'Google Play Services is available and up to date.';
        });
      } else {
        setState(() {
          _availabilityMessage = 'Google Play Services is not available or needs an update. '
                               'Please update Google Play Services to proceed.';
        });
        // Optionally, you could try to sign in, which might trigger a user prompt
        // to update Play Services if it's outdated.
        // await googleSignIn.signIn();
      }
    } catch (error) {
      setState(() {
        _availabilityMessage = 'Error checking Google Play Services: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Play Services Check'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  _availabilityMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkGooglePlayServicesAvailability,
                child: const Text('Re-check Availability'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
