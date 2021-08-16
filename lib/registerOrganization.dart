import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> registerOrganization(
    {required String referralCode, required String uid}) async {
  final _doc = await FirebaseFirestore.instance
      .collection('Organizations')
      .doc(referralCode)
      .get();
  if (_doc.exists) {
    await FirebaseFirestore.instance
        .doc('Organizations/$referralCode/Users/$uid')
        .set({'uid': uid});
  } else {
    throw 'Referral code invalid';
  }
}
