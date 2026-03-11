import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  XFile? _selectedImage;
  var _isAuthenticating = false;

  // 🚀 Login with GitHub
  Future<void> _githubLogin() async {
    try {
      setState(() { _isAuthenticating = true; });

      final githubProvider = GithubAuthProvider();
      final userCredentials = await _firebase.signInWithPopup(githubProvider);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': userCredentials.user!.displayName ?? 'GitHub User',
          'email': userCredentials.user!.email ?? '',
          'image_url': userCredentials.user!.photoURL ??
              'https://ui-avatars.com/api/?name=${userCredentials.user!.displayName}',
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub Login failed: ${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub Login failed: $error')),
        );
      }
    } finally {
      setState(() { _isAuthenticating = false; });
    }
  }

  // 🚀 Login with Google
  Future<void> _googleLogin() async {
    try {
      setState(() { _isAuthenticating = true; });

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '1042571644091-k0ckf6c8vciq7to3c0d16mtivq3gfk2b.apps.googleusercontent.com',
      ).signIn();
      if (googleUser == null) {
        setState(() { _isAuthenticating = false; });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredentials = await _firebase.signInWithCredential(credential);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': googleUser.displayName ?? 'Google User',
          'email': googleUser.email,
          'image_url': googleUser.photoUrl ??
              'https://ui-avatars.com/api/?name=${googleUser.displayName}',
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Login failed: $error')),
        );
      }
    } finally {
      setState(() { _isAuthenticating = false; });
    }
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid || (!_isLogin && _selectedImage == null)) return;
    _form.currentState!.save();

    try {
      setState(() { _isAuthenticating = true; });

      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        // ✅ ใช้ XFile.readAsBytes() รองรับ Web
        final imageBytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(imageBytes);
        final imageUrl = 'data:image/jpeg;base64,$base64Image';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Auth failed.')));
      }
      setState(() { _isAuthenticating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  width: 200,
                  child: Image.asset('assets/images/chat.png')),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                              onPickImage: (img) => _selectedImage = img),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => (val == null || !val.contains('@'))
                              ? 'Invalid email'
                              : null,
                          onSaved: (val) => _enteredEmail = val!,
                        ),
                        if (!_isLogin)
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Username'),
                            validator: (val) => (val == null || val.trim().length < 4)
                                ? 'Min 4 chars'
                                : null,
                            onSaved: (val) => _enteredUsername = val!,
                          ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (val) => (val == null || val.trim().length < 6)
                              ? 'Min 6 chars'
                              : null,
                          onSaved: (val) => _enteredPassword = val!,
                        ),
                        const SizedBox(height: 12),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating) ...[
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.login),
                            label: const Text('Sign in with Google'),
                            onPressed: _googleLogin,
                          ),
                          const SizedBox(height: 4),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.code),
                            label: const Text('Sign in with GitHub'),
                            onPressed: _githubLogin,
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isLogin = !_isLogin),
                            child: Text(_isLogin ? 'Create account' : 'I have account'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}