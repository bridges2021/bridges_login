import 'package:another_flushbar/flushbar.dart';
import 'package:bridges_login/DividerWithText.dart';
import 'package:bridges_login/SignInButton.dart';
import 'package:bridges_login/bridges_login.dart';
import 'package:bridges_login/createUserWithEmailAndPassword.dart';
import 'package:bridges_login/registerOrganization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'UserProfile.dart';
import 'registerNewOrganization.dart';

void flush(String errorText, BuildContext context) {
  Flushbar(
    margin: EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    duration: Duration(seconds: 5),
    message: errorText,
  )..show(context);
}

/// This view can control user sign in, load user data by user ID.
class BridgesLoginView extends StatefulWidget {
  /// The title.
  final String title;

  /// What to show after splash.
  final Widget child;

  /// Return user profile
  final Function(UserProfile userProfile) whenDone;

  /// Open sign in with Apple option, default to be true.
  final bool signInWithApple;

  /// Open sign in with Google option, default to be true.
  final bool signInWithGoogle;

  /// Open sign in with Email option, default to be true.
  final bool signInWithEmail;

  /// Open sign in with PhoneNumber option, default to be true.
  final bool signInWithPhoneNumber;

  final bool allowRegisterNewOrganization;

  const BridgesLoginView(
      {Key? key,
      this.title = 'Bridges',
      required this.child,
      required this.whenDone,
      this.signInWithApple = true,
      this.signInWithEmail = true,
      this.signInWithGoogle = true,
      this.signInWithPhoneNumber = true,
      this.allowRegisterNewOrganization = true})
      : super(key: key);

  @override
  _BridgesLoginViewState createState() => _BridgesLoginViewState();
}

class _BridgesLoginViewState extends State<BridgesLoginView> {
  User? _user;
  bool get _userValid => _user!.displayName != null;

  /// email verify bug
  // bool get _userValid => _user!.displayName != null && _user!.emailVerified;
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, AsyncSnapshot<User?> userSnapshot) {
        if (userSnapshot.hasError) {
          return _errorView(userSnapshot.error.toString());
        }

        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingView();
        }

        if (userSnapshot.data != null) {
          _user = userSnapshot.data;
          if (_userValid) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collectionGroup('Users')
                  .where('uid', isEqualTo: _user!.uid)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return _errorView(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _loadingView();
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  userProfile = UserProfile(
                      uid: _user!.uid,
                      name: _user!.displayName!,
                      role: Role.values
                          .elementAt(snapshot.data!.docs.first.data()['role']),
                      registerDate: snapshot.data!.docs.first
                          .data()['registerDate']
                          .toDate(),
                      organizations: snapshot.data!.docs
                          .map((e) => e.reference.parent.parent!)
                          .toList());
                  widget.whenDone(userProfile!);
                  return widget.child;
                } else {
                  return _registerOrganizationView();
                }
              },
            );
          } else {
            /// email verify bug
            // if (!_user!.emailVerified) {
            //   return _emailVerifiedView();
            // }
            if (_user!.displayName == null) {
              return _displayNameView();
            }
            return _errorView('Verification error');
          }
        } else {
          return _createAndSignInView();
        }
      },
    );
  }

  Widget _registerOrganizationView() {
    final _controller = TextEditingController();
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.title}'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(30),
            children: [
              Text(
                'Enter your referral code.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              Padding(padding: const EdgeInsets.only(bottom: 20)),
              Visibility(
                  visible: widget.allowRegisterNewOrganization,
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    _registerNewOrganizationView()));
                      },
                      child: Text('Register a new organization'))),
              Padding(padding: const EdgeInsets.only(bottom: 20)),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: 'Referral code', border: InputBorder.none),
              ),
              Padding(padding: const EdgeInsets.only(bottom: 20)),
              ElevatedButton(
                  onPressed: () async {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => _loadingView()));
                    await registerOrganization(
                            referralCode: _controller.text,
                            uid: _user!.uid,
                            name: _user!.displayName!)
                        .then((value) {
                      // Navigator.pop(context);
                    }).onError((error, stackTrace) {
                      // Navigator.pop(context);
                      flush(error.toString(), context);
                    });
                  },
                  child: Text('Next'))
            ],
          ),
        );
      },
    );
  }

  Widget _registerNewOrganizationView() {
    final _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Text(
            'Enter your organization name.',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
                hintText: 'Organization name', border: InputBorder.none),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          ElevatedButton(
              onPressed: () async {
                registerNewOrganization(
                        organizationName: _controller.text,
                        uid: _user!.uid,
                        name: _user!.displayName!)
                    .then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }).onError((error, stackTrace) {
                  Navigator.pop(context);
                  flush(error.toString(), context);
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _loadingView()));
              },
              child: Text('Register'))
        ],
      ),
    );
  }

  Widget _errorView(String errorString) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.error), Text(errorString)],
        ),
      ),
    );
  }

  Widget _loadingView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headline6,
            ),
            CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }

  Widget _emailVerifiedView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            Text(
              'Please verify your email.',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            ElevatedButton(
                onPressed: () async {
                  flush('A email just sent', context);
                  await _user!.sendEmailVerification();
                },
                child: Text('Send')),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text('Next'))
          ],
        ),
      ),
    );
  }

  Widget _displayNameView() {
    final _controller = TextEditingController();
    return StatefulBuilder(builder: (context, setState) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.title}'),
        ),
        body: Center(
          child: ListView(
            padding: EdgeInsets.all(30),
            children: [
              Center(
                child: Text(
                  'Enter your name.',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                decoration:
                    InputDecoration(hintText: 'Name', border: InputBorder.none),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              ElevatedButton(
                  onPressed: () async {
                    _user!
                        .updateDisplayName(_controller.text)
                        .then((value) => Navigator.pop(context))
                        .onError((error, stackTrace) {
                      Navigator.pop(context);
                      flush(error.toString(), context);
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _loadingView()));
                  },
                  child: Text('Next')),
            ],
          ),
        ),
      );
    });
  }

  Widget _createAndSignInView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => _createView()));
                      },
                      child: Text('Create account'))),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => _signInView()));
                  },
                  child: Text('Sign in'))
            ],
          ),
        ),
      ),
    );
  }

  Widget _createView() {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Text(
            'Create account with Email address and Password.',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                hintText: 'Email address', border: InputBorder.none),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          TextFormField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  hintText: 'Password', border: InputBorder.none)),
          Padding(padding: EdgeInsets.only(bottom: 20)),
          SignInButton(
              icon: Icons.email,
              text: 'Create account with Email',
              onPressed: () async {
                createUserWithEmailAndPassword(
                        _emailController.text, _passwordController.text)
                    .then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }).onError((error, stackTrace) {
                  Navigator.pop(context);
                  flush(error.toString(), context);
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _loadingView()));
              })
        ],
      ),
    );
  }

  Widget _signInView() {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        children: [
          Text(
            'Sign in your account',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Email address'),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          TextFormField(
            obscureText: true,
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'Password'),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          SignInButton(
              icon: Icons.email,
              text: 'Sign in with Email',
              onPressed: () {
                signInWithEmail(_emailController.text, _passwordController.text)
                    .then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }).onError((error, stackTrace) {
                  Navigator.pop(context);
                  flush(error.toString(), context);
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _loadingView()));
              }),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          DividerWithText(text: 'or'),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          SignInButton(
              icon: Icons.phone,
              text: 'Sign in with Phone',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => _signInWithPhoneView()));
              }),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          DividerWithText(text: 'or'),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          SignInButton(
            icon: FontAwesomeIcons.google,
            text: 'Sign in with Google',
            onPressed: () {
              signInWithGoogle().then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
              }).onError((error, stackTrace) {
                Navigator.pop(context);
                flush(error.toString(), context);
              });
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => _loadingView()));
            },
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          DividerWithText(text: 'or'),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          SignInWithAppleButton(onPressed: () {
            signInWithApple().then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            }).onError((error, stackTrace) {
              Navigator.pop(context);
              flush(error.toString(), context);
            });
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => _loadingView()));
          })
        ],
      ),
    );
  }

  Widget _signInWithPhoneView() {
    final _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Text(
            'Sign in with your phone number',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
                prefixText: '+852',
                hintText: 'Phone number',
                border: InputBorder.none),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          SignInButton(
              icon: Icons.message,
              text: 'Send',
              onPressed: () async {
                await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: '+852${_controller.text}',
                    verificationCompleted:
                        (PhoneAuthCredential credential) async {
                      await FirebaseAuth.instance
                          .signInWithCredential(credential);
                    },
                    verificationFailed: (FirebaseAuthException e) async {
                      if (e.code == 'invalid-phone-number') {
                        flush('Phone number is invalid', context);
                      }
                      flush(e.toString(), context);
                    },
                    codeSent: (String verificationId, int? resendToken) async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  _smsCodeVerifyView(verificationId)));
                    },
                    timeout: const Duration(seconds: 60),
                    codeAutoRetrievalTimeout: (String verificationId) {});
              })
        ],
      ),
    );
  }

  Widget _smsCodeVerifyView(String verificationId) {
    final _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Text(
            'Enter the sms code you received',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          TextFormField(
            controller: _controller,
            decoration:
                InputDecoration(hintText: 'SMS code', border: InputBorder.none),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20)),
          SignInButton(
              icon: Icons.phone,
              text: 'Sign in with phone',
              onPressed: () async {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: verificationId, smsCode: _controller.text);
                FirebaseAuth.instance
                    .signInWithCredential(credential)
                    .then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }).onError((error, stackTrace) {
                  Navigator.pop(context);
                  flush(error.toString(), context);
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _loadingView()));
              })
        ],
      ),
    );
  }
}
