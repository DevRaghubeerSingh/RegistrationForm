import 'package:firebaseapp/pages/dashboard_screen.dart';
import 'package:firebaseapp/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var isLoading = false;
  var email = "", name = "", password = "";
  var showValidationError = false;
  var obscurePassword = true;

  void login() async {
    if (email != "" && password != "") {
      setState(() {
        showValidationError = false;
        isLoading = true;
      });

      try {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          if (!context.mounted) return;
          toastification.show(
              context: context,
              title: const Text('Signed in successfully'),
              autoCloseDuration: const Duration(seconds: 5));

          await Future.delayed(const Duration(milliseconds: 250));

          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false);
        }
      } catch (e) {
        if (!context.mounted) return;
        toastification.show(
            context: context,
            title: Text(e.toString()),
            autoCloseDuration: const Duration(seconds: 5));
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        showValidationError = true;
      });
    }
  }

  void onEmailChange(emailTemp) {
    setState(() {
      email = emailTemp;
    });
  }

  void onPasswordChange(passwordTemp) {
    setState(() {
      password = passwordTemp;
    });
  }

  void onObscurePasswordClick() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void backFunc() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 37, 33, 243),
        appBar: AppBar(
          title: const Text("Login"),
          centerTitle: true,
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: showValidationError
                              ? Colors.red
                              : const Color.fromARGB(255, 37, 33, 243),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(2, 2),
                                color: showValidationError
                                    ? Colors.white
                                    : const Color.fromARGB(255, 37, 33, 243))
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: Text(
                        (showValidationError
                            ? "Please enter correct details"
                            : ""),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      onChanged: onEmailChange,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                        onChanged: onPasswordChange,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Create your password',
                            hintStyle: const TextStyle(color: Colors.white),
                            suffix: GestureDetector(
                                onTap: onObscurePasswordClick,
                                child: Icon(
                                  (obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  color: Colors.white,
                                )))),
                    const SizedBox(
                      height: 50,
                    ),
                    RawMaterialButton(
                      onPressed: login,
                      fillColor: Colors.white,
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
