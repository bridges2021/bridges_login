import 'package:firebase_auth/firebase_auth.dart';

Future<void> createUserWithEmailAndPassword(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

  } catch (e) {
    throw e;
  }
}