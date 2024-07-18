import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/pages/main_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "";
  final authInstance = FirebaseAuth.instance;
  String profileUrl = "";
  final storageInstance = FirebaseStorage.instance;
  final storeInstance = FirebaseFirestore.instance;

  void signout() async {
    await authInstance.signOut();
    if (!context.mounted) return;
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  @override
  void initState() {
    super.initState();

    loadPicture();
    loadUserName();
  }

  void loadPicture() async {
    final imageUrl = await storageInstance
        .ref()
        .child("profile_picture")
        .child(authInstance.currentUser!.uid)
        .getDownloadURL();
    setState(() {
      profileUrl = imageUrl;
    });
  }

  void loadUserName() async {
    var docRef =
        storeInstance.collection("Users").doc(authInstance.currentUser!.uid);

    docRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final uName = documentSnapshot.get("name");
        setState(() {
          userName = "$uName";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 33, 243),
      appBar: AppBar(
        title: const Center(
          child: Text("Dashboard"),
        ),
      ),
      body: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(profileUrl),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                userName != "" ? "Welcome welcome 👋" : "",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 100,
              ),
              RawMaterialButton(
                onPressed: signout,
                fillColor: Colors.white,
                child: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
