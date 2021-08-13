import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithEmail(
    String email, String password) async {
  final _userCred = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
  return _userCred;
}
