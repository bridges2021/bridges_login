import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> registerOrganization(
    {required String referralCode, required String uid, required String name}) async {
  final _doc = await FirebaseFirestore.instance
      .collection('Organizations')
      .doc(referralCode)
      .get();
  if (_doc.exists) {
    await FirebaseFirestore.instance
        .doc('Organizations/$referralCode/Users/$uid')
        .set({'uid': uid, 'role': 2, 'name': name, 'registerDate': DateTime.now()});
  } else {
    throw 'Referral code invalid';
  }
}
