import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/pages/dashboard_screen.dart';
import 'package:firebaseapp/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var validationMessage = "";
  var isLoading = false;
  var email = "", name = "", password = "", confirmPassword = "";
  var showValidationError = false;
  var obscurePassword = true, confirmObscurePassword = true;
  var picturePath = "";
  ImagePicker picker = ImagePicker();
  final authInstance = FirebaseAuth.instance;
  final storeInstance = FirebaseFirestore.instance;
  final storageInstance = FirebaseStorage.instance;

  void backFunc() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  void register() async {
    if (email != "" &&
        name != "" &&
        password != "" &&
        confirmPassword != "" &&
        picturePath != "") {
      if (password == confirmPassword) {
        setState(() {
          showValidationError = false;
          isLoading = true;
        });

        try {
          final credential = await authInstance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (credential.user != null) {
            if (!context.mounted) return;
            toastification.show(
                context: context,
                title: const Text('Account created successfully'),
                autoCloseDuration: const Duration(seconds: 5));

            await storeInstance
                .collection("Users")
                .doc(authInstance.currentUser!.uid)
                .set({"name": name, "email": email});

            final imagesRef = storageInstance
                .ref()
                .child("profile_picture")
                .child(authInstance.currentUser!.uid);

            File file = File(picturePath);

            try {
              await imagesRef.putFile(file);
            } on FirebaseException catch (e) {
              if (!context.mounted) return;
              toastification.show(
                  context: context,
                  title: Text(e.toString()),
                  autoCloseDuration: const Duration(seconds: 5));
            }

            await Future.delayed(const Duration(milliseconds: 250));
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false);
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            if (!context.mounted) return;
            toastification.show(
                context: context,
                title: const Text('The password provided is too weak.'),
                autoCloseDuration: const Duration(seconds: 5));
          } else if (e.code == 'email-already-in-use') {
            if (!context.mounted) return;
            toastification.show(
                context: context,
                title: const Text('The account already exists for that email.'),
                autoCloseDuration: const Duration(seconds: 5));
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
          validationMessage = "Passwords do not match";
        });
      }
    } else {
      setState(() {
        showValidationError = true;
        validationMessage = "Please enter all details";
      });
    }
  }

  void onEmailChange(emailTemp) {
    setState(() {
      email = emailTemp;
    });
  }

  void onNameChange(nameTemp) {
    setState(() {
      name = nameTemp;
    });
  }

  void addPicture() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      picturePath = image != null ? (image.path) : "";
    });
  }

  void onPasswordChange(passwordTemp) {
    setState(() {
      password = passwordTemp;
    });
  }

  void onConfirmPasswordChange(passwordTemp) {
    setState(() {
      confirmPassword = passwordTemp;
    });
  }

  void onObscurePasswordClick() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void onConfirmObscurePasswordClick() {
    setState(() {
      confirmObscurePassword = !confirmObscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 37, 33, 243),
        appBar: AppBar(
          title: const Text("Register"),
          centerTitle: true,
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 1,
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
                        (showValidationError ? validationMessage : ""),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CircleAvatar(
                        radius: 60,
                        backgroundImage: picturePath == ""
                            ? null
                            : Image.file(File(picturePath)).image),
                    const SizedBox(
                      height: 10,
                    ),
                    RawMaterialButton(
                      onPressed: addPicture,
                      fillColor: Colors.white,
                      child: const Text(
                        "Add Picture",
                        style: TextStyle(color: Colors.black),
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
                      onChanged: onNameChange,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your name',
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
                      height: 20,
                    ),
                    TextField(
                        onChanged: onConfirmPasswordChange,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: confirmObscurePassword,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Confirm your password',
                            hintStyle: const TextStyle(color: Colors.white),
                            suffix: GestureDetector(
                                onTap: onConfirmObscurePasswordClick,
                                child: Icon(
                                  (confirmObscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  color: Colors.white,
                                )))),
                    const SizedBox(
                      height: 50,
                    ),
                    RawMaterialButton(
                      onPressed: register,
                      fillColor: Colors.white,
                      child: const Text(
                        "Register",
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
