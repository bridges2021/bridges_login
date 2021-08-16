import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String uid;
  List<DocumentReference<Map<String, dynamic>>> organizations;
  DocumentReference<Map<String, dynamic>> get selectedOrganization => organizations.first;

  UserProfile({required this.uid, this.organizations = const []});

  Map<String, dynamic> get toMap => {
    'uid': uid,
    'organizations': organizations
  };
}
