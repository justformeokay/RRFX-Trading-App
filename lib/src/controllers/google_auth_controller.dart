import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInController extends GetxController {

  final GoogleSignIn signIn = GoogleSignIn.instance;
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

  Future<void> checkSignInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionSignIn = prefs.getString('sessionSignIn');
    if (sessionSignIn != null && sessionSignIn.isNotEmpty) {
      idToken(sessionSignIn);
      name(prefs.getString('name') ?? "");
      email(prefs.getString('email') ?? "");
      displayPicture(prefs.getString('displayPicture') ?? "");
    }
  }

  // void loginWithGoogle() {
  //   try{
  //     unawaited(
  //       signIn.initialize(clientId: clientId, serverClientId: serverClientId).then((_) {
  //         signIn.authenticationEvents.listen(_handleAuthenticationEvent).onError(_handleAuthenticationError);
  //         signIn.attemptLightweightAuthentication();
  //       }),
  //     );
  //   } catch (e){
  //     return;
  //   }
  // }

  Future signInWithGoogle() async {
    try{
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e){
      return;
    }
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    await googleSignIn.signOut();
    await auth.signOut();
    // print("User Signed Out");
  }
}