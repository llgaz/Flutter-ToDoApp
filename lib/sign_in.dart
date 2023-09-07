import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo/todo_app.dart';
import 'package:todo/shared_preferences.dart';
import 'package:hexcolor/hexcolor.dart';
import 'colors.dart';
import 'sign_up.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn(BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        await SharedPreferencesService.saveLoggedInStatus(
            true); // Oturum durumunu kaydet
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => YapilacaklarAnaSayfa()),
        );
      }
    } catch (e) {
      print("Error during sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign in failed. Please check your credentials."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(appBarColor),
        title: const Column(
          children: [
            Text("Welcome,"),
            Text(
              "ToDo App",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 33),
            )
          ],
        ),
        centerTitle: true,
        toolbarHeight: 135, // AppBar genişliğini ayarlayın
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 80),

            TextField(
              cursorColor: Colors.black,
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  )),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor(appBarColor),
                  padding: const EdgeInsets.fromLTRB(130, 10, 130, 10),
                  shape: const StadiumBorder()),
              onPressed: () => _signIn(context),
              child: const Text(
                'Sign In',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25), // Aralık ekledik
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: const Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
