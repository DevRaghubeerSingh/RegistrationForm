import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/pages/login_screen.dart';
import 'package:firebaseapp/pages/register_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final authInstance = FirebaseAuth.instance;

  void onRegisterPress() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  void onLoginPress() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 33, 243),
      appBar: AppBar(
        title: const Text("Registration Form"),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RawMaterialButton(
              onPressed: onRegisterPress,
              fillColor: Colors.white,
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.black),
              ),
            ),
            RawMaterialButton(
              onPressed: onLoginPress,
              fillColor: Colors.white,
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
