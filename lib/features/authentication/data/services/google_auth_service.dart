import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<String?> signIn() async {
    await _googleSignIn.initialize(
      serverClientId: '912270390373-2ri10svem7im403uohpc4ivc0ja98ife.apps.googleusercontent.com',
    );

    final account = await _googleSignIn.authenticate();

    final authentication = account.authentication;

    return authentication.idToken;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
