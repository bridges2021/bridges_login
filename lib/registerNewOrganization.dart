import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> registerNewOrganization(
    {required String organizationName, required String uid, required String name}) async {
  final _doc = await FirebaseFirestore.instance
      .collection('Organizations')
      .doc(organizationName)
      .get();
  if (_doc.exists) {
    throw 'Organization name in used';
  } else {
    await FirebaseFirestore.instance
        .doc('Organizations/$organizationName')
        .set({'createDate': DateTime.now()});
    await FirebaseFirestore.instance
        .doc('Organizations/$organizationName/Users/$uid')
        .set({'uid': uid, 'role': 0, 'registerDate': DateTime.now(), 'name': name});
  }
}
