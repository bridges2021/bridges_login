import 'package:bridges_login/bridges_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bridges login example app',
      home: MyView(),
    );
  }
}

class MyView extends StatefulWidget {
  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  UserProfile? _userProfile;

  @override
  Widget build(BuildContext context) {
    return BridgesLoginView(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Signed in'),
              ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  child: Text('Sign out')),
              Text(
                  'Current organization: ${_userProfile?.selectedOrganization.path}'),
              Text('Selectable organization'),
            ],
          ),
        ),
      ),
      whenDone: (userProfile) {
        _userProfile = userProfile;
      },
    );
  }
}
