import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String uid;
  Role role;
  DateTime registerDate;
  List<DocumentReference<Map<String, dynamic>>> organizations;
  DocumentReference<Map<String, dynamic>> get selectedOrganization => organizations.first;

  UserProfile({required this.uid, this.organizations = const [], required this.role, required this.registerDate});

  Map<String, dynamic> get toMap => {
    'uid': uid,
    'organizations': organizations,
    'role': role.index,
    'registerDate': registerDate
  };
}

enum Role {
  Owner,
  Editor,
  Viewer,
}