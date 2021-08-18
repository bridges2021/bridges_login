# bridges_login
## Installation
1. Add this lines to pubspec.yaml.
```yaml
bridges_login:
  git:
    url: https://github.com/bridges2021/bridges_login.git
    ref: main
```
2. Add this lines to ios/Runner/Info.plist for signInWithGoogle on IOS by manual or Xcode.
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

3. Register your app with SignInWithApple enabled on Apple's Developer Identifiers for Sign in with Apple on IOS.

## How to use
1. Wrap your widget with BridgesLoginView.
```dart
BridgesLoginView(
  child: MainView()
);
```
