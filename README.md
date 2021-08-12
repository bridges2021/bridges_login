# bridges_login
## Installation
1. Add this lines to pubspec.yaml.
```yaml
bridges_login:
  git:
    url: https://github.com/bridges2021/bridges_login.git
    ref: main
```
2. Add this lines to ios/Runner/Info.plist for signInWithGoogle on IOS by manual or Xcode
```plist
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- TODO Replace this value: -->
			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
			<string>com.googleusercontent.apps.861823949799-vc35cprkp249096uujjn0vvnmcvjppkn</string>
		</array>
	</dict>
</array>
```

## How to use
1. Wrap your widget with BridgesLoginView.
```dart
BridgesLoginView(
  child: MainView()
);
```
2. Return the user ID to onSplash, or other things to load when splashing.
```dart
onSplash: () async {
  return 'userId';
}
```
3. Add sign in method, leave it blank if not avaible, some default method is created in this package, you can also use your own method.
```dart
signInWithApple: signInWithApple,
signInWithGoogle: signInWithGoogle,
signInWithEmail: signInWithEmail,
signInWithPhoneNumver: signInWithPhoneNumber,
```
4. Load the user profile with user ID, and provide create profile function which triggered when user is new user.
```dart
createUserProfile: (id) async {
  FirebaseFirestore.instance.doc('Users/$id).set({});
}
getUserProfile: (id) async {
  FirebaseFirestore.instance.doc('Users/$id').get();
}
