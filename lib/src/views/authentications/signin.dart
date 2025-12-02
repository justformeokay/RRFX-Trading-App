import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:rrfx/src/components/alerts/popup.dart';
// import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
// import 'package:rrfx/src/components/buttons/social_login_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/email_textfield.dart';
import 'package:rrfx/src/components/textfields/password_textfield.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/controllers/google_auth_controller.dart';
import 'package:rrfx/src/views/authentications/forgot.dart';
import 'package:rrfx/src/views/authentications/signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  List<IconData> imageURL = [CupertinoIcons.phone, CupertinoIcons.add_circled_solid];
  PageController pageController = PageController();
  GoogleSignInController googleSignInController = Get.put(GoogleSignInController());
  final _formKey = GlobalKey<FormState>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthController authController = Get.put(AuthController());
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          elevation: 0,
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome", style: GoogleFonts.inter(fontSize:35, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 1.0,)),
                    Text("back!", style: GoogleFonts.inter(fontSize: 35, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
                    const SizedBox(height: 5.0),
                    Text("Lihat pergerakan harga pasar global secara langsung, dengan chart interaktif dan analisis teknikal lengkap.", style: TextStyle(color: CustomColor.textThemeLightSoftColor, fontSize: 12)),
                    const SizedBox(height: 30.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EmailTextField(
                            requiredField: true,
                            readOnly: false,
                            useValidator: false,
                            fieldName: LanguageGlobalVar.EMAIL_ADDRESS.tr,
                            hintText: "Alamat Email",
                            labelText: "Alamat Email",
                            controller: emailController,
                          ),
                          PasswordTextField(
                            labelText: "Kata Sandi",
                            requiredField: true,
                            notUseValidator: true,
                            fieldName: LanguageGlobalVar.PASSWORD.tr,
                            controller: passwordController,
                            hintText: LanguageGlobalVar.PASSWORD.tr,
                          ),
                          TextButton(
                            onPressed: () => Get.to(() => const Forgot()),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(
                                bottom: 24,
                              )
                            ),
                            child: Text(LanguageGlobalVar.LUPA.tr, style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: CustomColor.secondaryColor
                            ))
                          ),
                          SizedBox(
                            width: size.width,
                            child: Obx(
                              () => DefaultButton.defaultElevatedButton(
                                onPressed: authController.isLoading.value ? null : (){
                                  if(emailController.text.isEmpty || passwordController.text.isEmpty){
                                    AppSnackbar.error("Email dan kata sandi wajib diisi.");
                                    return;
                                  }
                                  if(_formKey.currentState!.validate()){
                                    authController.login(context, email: emailController.text, password: passwordController.text);
                                  }
                                },
                                title: authController.isLoading.value ? "Processing..." : LanguageGlobalVar.MASUK.tr
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(LanguageGlobalVar.NOT_HAVE_ACCOUNT.tr, style: GoogleFonts.inter(color: CustomColor.textThemeLightSoftColor, fontSize: 12)),
                                TextButton(
                                  onPressed: (){
                                      Get.to(() => const Signup());
                                    },
                                  style: TextButton.styleFrom(padding: EdgeInsets.only(left: 5)),
                                  child: Text(LanguageGlobalVar.REGIST_NOW.tr, style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: CustomColor.secondaryColor
                                  ))
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // SocialLoginButton(
                          //   icon: FontAwesome.google_brand,
                          //   title: "Sign in with Google",
                          //   iconColor: Colors.white,
                          //   onPressed: authController.isLoading.value ? null : () async {
                          //     // await GoogleSignIn.instance.authenticate();
                          //     FeatureUnderDevPopup.show();
                          //   },
                          // ),

                          // const SizedBox(height: 10),

                          // SocialLoginButton(
                          //   icon: FontAwesome.facebook_f_brand,
                          //   title: "Sign in with Facebook",
                          //   iconColor: Colors.white,
                          //   onPressed: authController.isLoading.value ? null : () {
                          //     FeatureUnderDevPopup.show();
                          //   }
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
