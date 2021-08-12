import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// This view can control user sign in, load user data by user ID
class BridgesLoginView extends StatefulWidget {
  const BridgesLoginView({
    Key? key,
    required this.onSplash,
    this.title = 'ELLIE',
    required this.child,
    required this.onUserLoad,
    this.signInWithEmail,
    this.signInWithApple,
    this.signInWithGoogle,
    this.signInWithPhoneNumber,
  }) : super(key: key);

  final String title;
  final Future<bool> Function() onSplash;
  final Widget child;
  final Future<void> Function() onUserLoad;
  final Future<UserCredential> Function(
      String email, String password, String name)? signInWithEmail;
  final Future<UserCredential> Function()? signInWithGoogle;
  final Future<UserCredential> Function()? signInWithApple;
  final Future<void> Function(String phoneNumber, String smsCode)?
      signInWithPhoneNumber;

  @override
  _BridgesLoginViewState createState() => _BridgesLoginViewState();
}

class _BridgesLoginViewState extends State<BridgesLoginView> {
  bool _haveUser = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _haveUser = await widget.onSplash();
    if (_haveUser) {
      await widget.onUserLoad();
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
    } else if (_haveUser) {
      return widget.child;
    } else {
      return _NoUserView(
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
      this.signInWithPhoneNumber})
      : super(key: key);
  final String title;
  final Widget child;

  final Future<UserCredential> Function(
      String email, String password, String name)? signInWithEmail;
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
  _CreateUserView({Key? key, required this.title, required this.child})
      : super(key: key);
  final String title;
  final Widget child;

  @override
  __CreateUserViewState createState() => __CreateUserViewState();
}

class __CreateUserViewState extends State<_CreateUserView> {
  final _formKey = GlobalKey<FormState>();

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
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                decoration:
                    InputDecoration(border: InputBorder.none, hintText: 'Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Email address'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => _LoadingView(
                          title: widget.title,
                          onLoad: () async {},
                          child: widget.child)));
            },
          ),
        ),
      ),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView(
      {Key? key,
      required this.title,
      required this.child,
      this.signInWithGoogle,
      this.signInWithApple,
      this.signInWithEmail,
      this.signInWithPhoneNumber})
      : super(key: key);

  final String title;
  final Widget child;

  final Future<UserCredential> Function(
      String email, String password, String name)? signInWithEmail;
  final Future<UserCredential> Function()? signInWithGoogle;
  final Future<UserCredential> Function()? signInWithApple;
  final Future<void> Function(String phoneNumber, String smsCode)?
      signInWithPhoneNumber;

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
      height: 40,
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
        title: Text(title),
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
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Email address'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Password',
              ),
            ),
          ),
          signInWithPhoneNumber != null
              ? dividerText(Theme.of(context).dividerColor)
              : Container(),
          signInWithPhoneNumber != null
              ? signInWithButton(
                  Icon(Icons.phone),
                  'Phone',
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _SignInWithPhoneNumberView(
                                title: title,
                              ))))
              : Container(),
          signInWithApple != null && Platform.isIOS && kIsWeb
              ? dividerText(Theme.of(context).dividerColor)
              : Container(),
          signInWithApple != null && Platform.isIOS && kIsWeb
              ? signInWithButton(
                  Icon(FontAwesomeIcons.apple),
                  'Apple',
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _LoadingView(
                              title: title,
                              onLoad: () async {
                                await signInWithApple!();
                              },
                              child: child))))
              : Container(),
          signInWithGoogle != null
              ? dividerText(Theme.of(context).dividerColor)
              : Container(),
          signInWithGoogle != null
              ? signInWithButton(
                  Icon(FontAwesomeIcons.google),
                  'Google',
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _LoadingView(
                              title: title,
                              onLoad: () async {},
                              child: child))))
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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => _LoadingView(
                            title: title,
                            onLoad: () async {},
                            child: child,
                          )));
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
      this.timeLimit = const Duration(seconds: 30),
      required this.child})
      : super(key: key);
  final Future<void> Function() onLoad;
  final Duration duration;
  final String title;
  final Widget child;
  final Duration timeLimit;

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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: SpinKitCircle(
            color: Theme.of(context).primaryColor,
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

class _SignInWithPhoneNumberView extends StatelessWidget {
  const _SignInWithPhoneNumberView({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Center(
            child: Text(
              'Sign in with Phone number',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          TextFormField(),
        ],
      ),
    );
  }
}
