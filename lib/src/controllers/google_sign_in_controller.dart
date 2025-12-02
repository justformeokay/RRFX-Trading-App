import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInController extends GetxController {

  RxString name = "".obs;
  RxString email = "".obs;
  RxString displayPicture = "".obs;
  RxString idToken = "".obs;

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: '257178292848-2s2fldv6r67cknrj2nb836g8jv9vm9ng.apps.googleusercontent.com');

    googleSignIn.authenticationEvents.listen((GoogleSignInAuthenticationEvent event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        idToken(event.user.authentication.idToken);
        email(event.user.email);
        name(event.user.displayName);
        displayPicture(event.user.photoUrl);

        if (idToken.value == "") {
          return;
        }
        _handleSessionSignIn(idToken.value, name.value, email.value, displayPicture.value);
      }
    });
  }

  Future<void> _handleSessionSignIn(String id, name, email, displayPicture) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionSignIn', id);
    prefs.setString('name', name);
    prefs.setString('email', email);
    prefs.setString('displayPicture', displayPicture);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    await googleSignIn.signOut();
    await auth.signOut();
  }
}