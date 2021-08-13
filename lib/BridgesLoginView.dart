import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// This view can control user sign in, load user data by user ID
class BridgesLoginView extends StatefulWidget {
  const BridgesLoginView(
      {Key? key,
      required this.onSplash,
      this.title = 'ELLIE',
      required this.child,
      required this.getUserProfile,
      this.signInWithEmail,
      this.signInWithApple,
      this.signInWithGoogle,
      this.signInWithPhoneNumber,
      required this.createUserProfile})
      : super(key: key);

  final String title;
  final Future<String?> Function() onSplash;
  final Widget child;
  final Future<void> Function(String id) getUserProfile;
  final Future<UserCredential> Function(String email, String password)?
      signInWithEmail;
  final Future<UserCredential> Function()? signInWithGoogle;
  final Future<UserCredential> Function()? signInWithApple;
  final Future<void> Function(String phoneNumber, String smsCode)?
      signInWithPhoneNumber;
  final Future<void> Function(String uid) createUserProfile;

  @override
  _BridgesLoginViewState createState() => _BridgesLoginViewState();
}

class _BridgesLoginViewState extends State<BridgesLoginView> {
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await widget.onSplash();
    if (_userId != null) {
      await widget.getUserProfile(_userId!);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _textTheme = Theme.of(context).textTheme;
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: _textTheme.headline6,
              ),
              CircularProgressIndicator.adaptive()
            ],
          ),
        ),
      );
    } else if (_userId != null) {
      return widget.child;
    } else {
      return _NoUserView(
          createUserProfile: widget.createUserProfile,
          getUserProfile: widget.getUserProfile,
          title: widget.title,
          child: widget.child,
          signInWithGoogle: widget.signInWithGoogle,
          signInWithEmail: widget.signInWithEmail,
          signInWithApple: widget.signInWithApple,
          signInWithPhoneNumber: widget.signInWithPhoneNumber);
    }
  }
}

class _NoUserView extends StatelessWidget {
  const _NoUserView(
      {Key? key,
      required this.title,
      required this.child,
      this.signInWithEmail,
      this.signInWithGoogle,
      this.signInWithApple,
      this.signInWithPhoneNumber,
      required this.getUserProfile,
      required this.createUserProfile})
      : super(key: key);
  final String title;
  final Widget child;
  final Future<void> Function(String id) getUserProfile;
  final Future<void> Function(String uid) createUserProfile;

  final Future<UserCredential> Function(String email, String password)?
      signInWithEmail;
  final Future<UserCredential> Function()? signInWithGoogle;
  final Future<UserCredential> Function()? signInWithApple;
  final Future<void> Function(String phoneNumber, String smsCode)?
      signInWithPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => _CreateUserView(
                                        getUserProfile: getUserProfile,
                                        createUserProfile: createUserProfile,
                                        title: title,
                                        child: child,
                                      )));
                        },
                        child: Text(
                          'Create user',
                        )),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => _SignInView(
                                    createUserProfile: createUserProfile,
                                    getUserProfile: getUserProfile,
                                    title: title,
                                    child: child,
                                    signInWithApple: signInWithApple,
                                    signInWithEmail: signInWithEmail,
                                    signInWithGoogle: signInWithGoogle,
                                    signInWithPhoneNumber:
                                        signInWithPhoneNumber,
                                  )));
                    },
                    child: Text(
                      'Sign in',
                    ))
              ],
            ),
          ),
        ));
  }
}

class _CreateUserView extends StatefulWidget {
  _CreateUserView(
      {Key? key,
      required this.title,
      required this.child,
      required this.createUserProfile,
      required this.getUserProfile})
      : super(key: key);
  final String title;
  final Widget child;
  final Future<void> Function(String uid) createUserProfile;
  final Future<void> Function(String id) getUserProfile;

  @override
  __CreateUserViewState createState() => __CreateUserViewState();
}

class __CreateUserViewState extends State<_CreateUserView> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        child: ListView(
          key: _formKey,
          padding: EdgeInsets.all(30),
          shrinkWrap: true,
          children: [
            Center(
                child: Text(
              'Create your account',
              style: _textTheme.headline6,
            )),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                onChanged: (input) => setState(() => _name = input),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                decoration:
                    InputDecoration(border: InputBorder.none, hintText: 'Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                onChanged: (input) => setState(() => _email = input),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Email address'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                onChanged: (input) => setState(() => _password = input),
                onFieldSubmitted: (input) {
                  if (_name.isNotEmpty &&
                      _email.isNotEmpty &&
                      _password.isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _LoadingView(
                                email: _email,
                                password: _password,
                                title: widget.title,
                                onLoad: () async {
                                  try {
                                    final _cred = await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: _email, password: _password);
                                    if (_cred.user != null) {
                                      if (_cred.additionalUserInfo!.isNewUser) {
                                        await _cred.user!
                                            .updateDisplayName(_name);
                                        await widget
                                            .createUserProfile(_cred.user!.uid);
                                      }
                                      if (!_cred.user!.emailVerified) {
                                        await _cred.user!
                                            .sendEmailVerification();
                                        await FirebaseAuth.instance.signOut();
                                        throw 'email not verified';
                                      }

                                      await widget
                                          .getUserProfile(_cred.user!.uid);
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'weak-password') {
                                      throw 'The password provided is too weak.';
                                    } else if (e.code ==
                                        'email-already-in-use') {
                                      throw 'The account already exists for that email.';
                                    }
                                  } catch (e) {
                                    throw e;
                                  }
                                },
                                child: widget.child)));
                  }
                },
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Password',
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ElevatedButton(
            child: Text('Create'),
            onPressed: _name.isEmpty && _password.isEmpty && _email.isEmpty
                ? null
                : () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _LoadingView(
                                email: _email,
                                password: _password,
                                title: widget.title,
                                onLoad: () async {
                                  try {
                                    final _cred = await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: _email, password: _password);
                                    if (_cred.user != null) {
                                      if (_cred.additionalUserInfo!.isNewUser) {
                                        await _cred.user!
                                            .updateDisplayName(_name);
                                        await widget
                                            .createUserProfile(_cred.user!.uid);
                                      }
                                      if (!_cred.user!.emailVerified) {
                                        await _cred.user!
                                            .sendEmailVerification();
                                        await FirebaseAuth.instance.signOut();
                                        throw 'email not verified';
                                      }

                                      await widget
                                          .getUserProfile(_cred.user!.uid);
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'weak-password') {
                                      throw 'The password provided is too weak.';
                                    } else if (e.code ==
                                        'email-already-in-use') {
                                      throw 'The account already exists for that email.';
                                    }
                                  } catch (e) {
                                    throw e;
                                  }
                                },
                                child: widget.child)));
                  },
          ),
        ),
      ),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView(
      {Key? key,
      required this.title,
      required this.child,
      this.signInWithGoogle,
      this.signInWithApple,
      this.signInWithEmail,
      this.signInWithPhoneNumber,
      required this.getUserProfile,
      required this.createUserProfile})
      : super(key: key);

  final String title;
  final Widget child;
  final Future<void> Function(String id) getUserProfile;
  final Future<void> Function(String uid) createUserProfile;

  final Future<UserCredential> Function(String email, String password)?
      signInWithEmail;
  final Future<UserCredential> Function()? signInWithGoogle;
  final Future<UserCredential> Function()? signInWithApple;
  final Future<void> Function(String phoneNumber, String smsCode)?
      signInWithPhoneNumber;

  @override
  __SignInViewState createState() => __SignInViewState();
}

class __SignInViewState extends State<_SignInView> {
  String _email = '';
  String _password = '';

  Widget dividerText(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'or',
              style: TextStyle(color: color),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget signInWithButton(Icon icon, String text, Function() onPressed) {
    return Container(
      height: 44,
      child: ElevatedButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              Container(
                width: 20,
              ),
              Text('Sign in with $text')
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        shrinkWrap: true,
        children: [
          Center(
              child: Text(
            'Sign in your account',
            style: _textTheme.headline6,
          )),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              onChanged: (input) {
                setState(() {
                  _email = input;
                });
              },
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Email address'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              onChanged: (input) {
                _password = input;
              },
              onFieldSubmitted: (input) {
                if (_email.isNotEmpty && _password.isNotEmpty) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _LoadingView(
                              title: widget.title,
                              onLoad: () async {
                                final _userCred = await widget.signInWithEmail!(
                                    _email, _password);
                                if (_userCred.user != null) {
                                  if (_userCred.additionalUserInfo!.isNewUser) {
                                    await widget
                                        .createUserProfile(_userCred.user!.uid);
                                  }
                                  if (!_userCred.user!.emailVerified) {
                                    await _userCred.user!
                                        .sendEmailVerification();
                                    await FirebaseAuth.instance.signOut();

                                    throw 'email not verified on sign in';
                                  }

                                  await widget
                                      .getUserProfile(_userCred.user!.uid);
                                }
                              },
                              child: widget.child)));
                }
              },
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Password',
              ),
            ),
          ),
          widget.signInWithPhoneNumber != null
              ? dividerText(Theme.of(context).dividerColor)
              : Container(),
          widget.signInWithPhoneNumber != null
              ? signInWithButton(
                  Icon(Icons.phone),
                  'Phone',
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _SignInWithPhoneNumberView(
                                title: widget.title,
                                signInWithPhoneNumber:
                                    widget.signInWithPhoneNumber,
                                child: widget.child,
                                getUserProfile: widget.getUserProfile,
                                createUserProfile: widget.createUserProfile,
                              ))))
              : Container(),
          widget.signInWithApple != null && (Platform.isIOS || kIsWeb)
              ? dividerText(Theme.of(context).dividerColor)
              : Container(),
          widget.signInWithApple != null && (Platform.isIOS || kIsWeb)
              ? SignInWithAppleButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _LoadingView(
                              title: widget.title,
                              onLoad: () async {
                                final _cred = await widget.signInWithApple!();
                                if (_cred.user != null) {
                                  if (_cred.additionalUserInfo!.isNewUser) {
                                    widget.createUserProfile(_cred.user!.uid);
                                  }
                                  widget.getUserProfile(_cred.user!.uid);
                                }
                              },
                              child: widget.child))))
              : Container(),
          widget.signInWithGoogle != null
              ? dividerText(Theme.of(context).dividerColor)
              : Container(),
          widget.signInWithGoogle != null
              ? signInWithButton(
                  Icon(FontAwesomeIcons.google),
                  'Google',
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _LoadingView(
                              title: widget.title,
                              onLoad: () async {
                                final _userCred =
                                    await widget.signInWithGoogle!();
                                if (_userCred.user != null) {
                                  if (_userCred.additionalUserInfo!.isNewUser) {
                                    await widget
                                        .createUserProfile(_userCred.user!.uid);
                                  }
                                  await widget
                                      .getUserProfile(_userCred.user!.uid);
                                }
                              },
                              child: widget.child))))
              : Container()
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ElevatedButton(
            child: Text('Sign in'),
            onPressed: _email.isEmpty && _password.isEmpty
                ? null
                : () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _LoadingView(
                                title: widget.title,
                                onLoad: () async {
                                  final _userCred = await widget
                                      .signInWithEmail!(_email, _password);
                                  if (_userCred.user != null) {
                                    if (_userCred
                                        .additionalUserInfo!.isNewUser) {
                                      await widget.createUserProfile(
                                          _userCred.user!.uid);
                                    }
                                    if (!_userCred.user!.emailVerified) {
                                      await _userCred.user!
                                          .sendEmailVerification();
                                      await FirebaseAuth.instance.signOut();

                                      throw 'email not verified on sign in';
                                    }

                                    await widget
                                        .getUserProfile(_userCred.user!.uid);
                                  }
                                },
                                child: widget.child)));
                  },
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatefulWidget {
  const _LoadingView(
      {Key? key,
      required this.title,
      required this.onLoad,
      this.duration = const Duration(seconds: 1),
      this.timeLimit = const Duration(seconds: 180),
      required this.child,
      this.email,
      this.password})
      : super(key: key);
  final Future<void> Function() onLoad;
  final Duration duration;
  final String title;
  final Widget child;
  final Duration timeLimit;
  final String? email;
  final String? password;

  @override
  __LoadingViewState createState() => __LoadingViewState();
}

class __LoadingViewState extends State<_LoadingView> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await Future.wait([Future.delayed(widget.duration), widget.onLoad()])
          .timeout(widget.timeLimit, onTimeout: () => throw ('Time out'));
    } catch (e) {
      _error = e.toString();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_error);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.title),
        ),
        body: Center(
          child: SpinKitCircle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    } else if (_error == 'email not verified') {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                'A email has just send to you, please verify.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser!
                      .sendEmailVerification();
                },
                child: Text('Send again'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    try {
                      final _userCred = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: widget.email!, password: widget.password!);
                      if (_userCred.user != null &&
                          _userCred.user!.emailVerified) {
                      } else {
                        await FirebaseAuth.instance.signOut();
                        throw 'email not verified';
                      }
                    } catch (e) {
                      print(e);
                      _error = e.toString();
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Text('next'))
            ],
          ),
        ),
      );
    } else if (_error == 'email not verified on sign in') {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                'A email has just send to you, please verify.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser!
                      .sendEmailVerification();
                },
                child: Text('Send again'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    await _init();
                  },
                  child: Text('next'))
            ],
          ),
        ),
      );
    } else if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                _error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    await _init();
                  },
                  child: Text('Retry'))
            ],
          ),
        ),
      );
    } else {
      return widget.child;
    }
  }
}

class _SignInWithPhoneNumberView extends StatefulWidget {
  _SignInWithPhoneNumberView(
      {Key? key,
      required this.title,
      required this.signInWithPhoneNumber,
      required this.child,
      required this.getUserProfile,
      required this.createUserProfile})
      : super(key: key);
  final String title;
  final Future<void> Function(String phoneNumber, String smsCode)?
      signInWithPhoneNumber;
  final Widget child;
  final Future<void> Function(String id) getUserProfile;
  final Future<void> Function(String uid) createUserProfile;

  @override
  __SignInWithPhoneNumberViewState createState() =>
      __SignInWithPhoneNumberViewState();
}

class __SignInWithPhoneNumberViewState
    extends State<_SignInWithPhoneNumberView> {
  String? _phoneNumber;
  String? _smsCode;
  String _phoneNumberError = '';

  String? _verificationId;

  Future<void> _signInWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) async {
          if (e.code == 'invalid-phone-number') {
            setState(() {
              _phoneNumberError = 'The provided phone number is not valid';
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          setState(() {
            _phoneNumberError = '';
          });
          setState(() {
            _verificationId = verificationId;
            print(_verificationId);
          });
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Center(
            child: Text(
              'Sign in with Phone number.',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                  hintText: 'Phone number',
                  errorText: _phoneNumberError,
                  border: InputBorder.none),
              onChanged: (input) {
                setState(() {
                  _phoneNumber = input;
                });
              },
            ),
          ),
          Visibility(
            visible: _verificationId != null,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                    hintText: 'Verification code', border: InputBorder.none),
                onChanged: (input) {
                  setState(() {
                    _smsCode = input;
                  });
                },
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
            padding: EdgeInsets.only(
                top: 10,
                left: 30,
                right: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _verificationId == null
                ? ElevatedButton(
                    onPressed: _phoneNumber == null || _phoneNumber == ''
                        ? null
                        : () async {
                            await _signInWithPhoneNumber();
                          },
                    child: Text('Send SMS'),
                  )
                : ElevatedButton(
                    onPressed: _smsCode == null || _smsCode == ''
                        ? null
                        : () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => _LoadingView(
                                        title: widget.title,
                                        onLoad: () async {
                                          final PhoneAuthCredential credential =
                                              PhoneAuthProvider.credential(
                                                  verificationId:
                                                      _verificationId!,
                                                  smsCode: _smsCode!);
                                          final _userCred = await FirebaseAuth
                                              .instance
                                              .signInWithCredential(credential);
                                          if (_userCred.user != null) {
                                            if (_userCred.additionalUserInfo!
                                                .isNewUser) {
                                              await widget.createUserProfile(
                                                  _userCred.user!.uid);
                                            }
                                            await widget.getUserProfile(
                                                _userCred.user!.uid);
                                          }
                                        },
                                        child: widget.child)));
                          },
                    child: Text('Sign in'))),
      ),
    );
  }
}
