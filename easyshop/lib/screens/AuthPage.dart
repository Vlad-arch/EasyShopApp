import 'package:easyshop/Views/admin_page.dart';
import 'package:easyshop/auth.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> authAction() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      if (isLogin) {
        if (_email.text.trim() == 'admin' && _password.text.trim() == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
          return;
        }
        await Auth().signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      } else {
        if (_name.text.trim().isEmpty) {
          throw FirebaseAuthException(code: "missing-name", message: "Inserisci il tuo nome completo.");
        }
        await Auth().createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
          name: _name.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Errore di autenticazione";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EasyShop'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? 'Bentornato' : 'Crea un Account',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              if (!isLogin) ...[
                TextField(
                  controller: _name,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : authAction,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isLogin ? 'Accedi' : 'Registrati',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? "Non hai un account? Registrati"
                      : "Hai già un account? Accedi",
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("OPPURE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });
                          try {
                            await Auth().signInWithGoogle();
                          } catch (e) {
                            if (e is FirebaseAuthException && e.code == 'google-sign-in-aborted') {
                              // Utente ha chiuso il popup di google
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Errore Google Login: ${e.toString()}"), backgroundColor: Colors.red),
                                );
                              }
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "G ",
                              style: TextStyle(color: Colors.red[600], fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Accedi con Google',
                              style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}