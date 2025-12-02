import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/views/mainpage.dart';

class SuccessSubmit extends StatefulWidget {
  const SuccessSubmit({super.key});

  @override
  State<SuccessSubmit> createState() => _SuccessSubmit();
}

class _SuccessSubmit extends State<SuccessSubmit> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.maxFinite,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              SizedBox(
                width: size.width / 2,
                child: Lottie.asset('assets/json/success.json', frameRate: FrameRate(60)),
              ),
              const SizedBox(height: 20),
              Text("Berhasil", style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.bold)),
              Text("Berhasil submit proses pembuatan real akun. Mohon tunggu 1x24 jam kerja untuk mengkonfirmasi pembuatan akun real anda", style: GoogleFonts.inter(fontSize: 16), textAlign: TextAlign.center),
              Spacer()
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: size.width,
            child: DefaultButton.defaultElevatedButton(
              onPressed: (){
                Get.offAll(() => const Mainpage());
              },
              title: LanguageGlobalVar.SELANJUTNYA.tr
            ),
          ),
        ),
      ),
    );
  }
}

