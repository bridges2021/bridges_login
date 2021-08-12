import 'package:flutter/foundation.dart';

import 'UserProfile.dart';

class Local with ChangeNotifier{
  bool isSignedIn = false;
  UserProfile? userProfile;

  Future<void> get() async {

  }
}