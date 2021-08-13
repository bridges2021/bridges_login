import 'package:bridges_login/bridges_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Phoenix(child: ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BridgesLoginView(
        onSplash: () async {
          print(FirebaseAuth.instance.currentUser?.uid);
          return FirebaseAuth.instance.currentUser?.uid;
        },
        signInWithApple: signInWithApple,
        signInWithGoogle: signInWithGoogle,
        signInWithEmail: signInWithEmail,
        signInWithPhoneNumber: signInWithPhoneNumber,
        createUserProfile: (id) async {
          FirebaseFirestore.instance.doc('Users/$id').set({
            'createDateTime': DateTime.now(),
            'name': FirebaseAuth.instance.currentUser!.displayName
          });
        },
        getUserProfile: (id) async {
          final _userProfile =
              await FirebaseFirestore.instance.doc('Users/$id').get();
          print(_userProfile.data());
        },
        child: MainView(),
      ),
    );
  }
}

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Bridges login view example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Text('Your are current signed in'),
          ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Phoenix.rebirth(context);
              },
              child: Text('Sign out'))
        ],
      ),
    );
  }
}
