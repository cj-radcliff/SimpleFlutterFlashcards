# Authentication Implementation Plan

This document outlines the steps to implement Google authentication in the Flutter application, with a Dart server handling the backend authentication logic.

## Frontend (Flutter Application)

### 1. Add Dependencies

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_sign_in: ^6.1.5
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.2
```

Then, run `flutter pub get`.

### 2. Configure Firebase

1.  Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  Add your Flutter application to the Firebase project for Android, iOS, and Web.
3.  Follow the setup instructions for each platform, including adding the `google-services.json` file to your Android app and the `GoogleService-Info.plist` file to your iOS app.
4.  Enable Google Sign-In as an authentication provider in the Firebase console.

### 3. Create a Login Screen

1.  Create a new screen with a "Sign in with Google" button.
2.  Implement the Google Sign-In flow when the button is pressed.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if (googleAuth == null) {
      throw Exception('Google sign in failed');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
}
```

### 4. Send ID Token to Backend

After a successful Google Sign-In, get the ID token and send it to your Dart server for verification.

```dart
// After signInWithGoogle() is successful
final idToken = await userCredential.user?.getIdToken();

// Send the idToken to your backend
final response = await http.post(
  Uri.parse('YOUR_BACKEND_URL/auth/google'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'token': idToken}),
);
```

### 5. Handle Backend Response

The backend will respond with a session token. Store this token securely on the device (e.g., using `flutter_secure_storage`) and use it for subsequent API requests.

### 6. Implement Logout

Create a method to sign the user out from both Firebase and Google.

```dart
Future<void> signOut() async {
  await _auth.signOut();
  await _googleSignIn.signOut();
}
```

## Backend (Dart Server)

### 1. [server work] Add Dependencies

Add the necessary dependencies to your Dart server's `pubspec.yaml` file for handling JWTs and verifying Google ID tokens. A good choice is `googleapis_auth`.

### 2. [server work] Create an Authentication Endpoint

Create a new endpoint (e.g., `/auth/google`) that accepts a POST request with the Google ID token in the body.

### 3. [server work] Verify the Google ID Token

Use the `googleapis_auth` library to verify the ID token with Google's servers.

```dart
import 'package:googleapis_auth/auth_io.dart';

Future<void> verifyToken(String token) async {
  final client = await clientViaIdToken(
    token,
    // You need to create an OAuth 2.0 client ID in the Google Cloud Console
    // for your server.
    ClientId('YOUR_SERVER_CLIENT_ID', null),
  );
  // If the token is invalid, this will throw an exception.
  // You can get user information from the client.
}
```

### 4. [server work] Create or Retrieve User

Once the token is verified, extract the user's information (e.g., email, name) from the token payload. Check if a user with this email already exists in your database. If not, create a new user.

### 5. [server work] Generate a Session Token

Generate your own session token (e.g., a JWT) for the user. This token will be used to authenticate subsequent requests to your server.

### 6. [server work] Implement Protected Routes

Create middleware that checks for a valid session token on protected routes. If the token is missing or invalid, return a `401 Unauthorized` error.
