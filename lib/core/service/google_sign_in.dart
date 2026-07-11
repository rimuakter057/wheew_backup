import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  Future<GoogleSignInAccount?> signIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
        '272591501803-lkbcu6dsv9hh99h1skotcom5crvbb78s.apps.googleusercontent.com',
      );

      final GoogleSignInAccount account =
      await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication auth = account.authentication;

      print('ID TOKEN: ${auth.idToken}');
      print('EMAIL: ${account.email}');
      print('NAME: ${account.displayName}');

      return account;
    } on GoogleSignInException catch (e) {
      print('CODE: ${e.code}');
      print('DESCRIPTION: ${e.description}');
      print('DETAILS: ${e.details}');
      return null;
    } catch (e) {
      print('ERROR: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.disconnect();
  }
}