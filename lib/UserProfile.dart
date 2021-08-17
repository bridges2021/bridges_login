import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String uid;
  String name;
  Role role;
  DateTime registerDate;
  List<DocumentReference<Map<String, dynamic>>> organizations;
  DocumentReference<Map<String, dynamic>> get selectedOrganization =>
      organizations.first;

  UserProfile(
      {required this.uid,
      required this.name,
      this.organizations = const [],
      required this.role,
      required this.registerDate});

  factory UserProfile.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final _data = snapshot.data() ?? {};
    return UserProfile(
        uid: _data['uid'],
        name: _data['name'],
        role: Role.values.elementAt(_data['role']),
        registerDate: _data['registerDate'].toDate());
  }

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
