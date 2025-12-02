import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/main.dart';
import 'package:rrfx/src/components/colors/default.dart';

class CustomAlert {
  static alertDialogSuccess(Function()? onTap){
    return Get.defaultDialog(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      radius: 30,
      barrierDismissible: false,
      title: "",
      content: Column(
        children: [
          Lottie.asset('assets/json/success.json', repeat: true,frameRate: const FrameRate(50)),
          const SizedBox(height: 10),
          Text("Berhasil", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 5),
          const Text("Berhasil membuat akun. Silahkan cek pesan masuk pada nomor HP yang anda daftarkan sebelumnya", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.white38), textAlign: TextAlign.center)
        ],
      ),
      actions: [
        SizedBox(
          width: 100,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              elevation: 5,
              backgroundColor: Colors.green
            ),
            onPressed: onTap,
            child: Text("Lanjutkan", style: GoogleFonts.inter(color: Colors.white
            ))),
          ),
        ]
    );
  }

  static alertDialogCustomSuccess(BuildContext context, {
    Function()? onTap,
    String? message,
    String? title,
    String? textButton,
  }) {
    return Get.defaultDialog(
      backgroundColor: Theme.of(context).cardColor, // untuk light theme
      radius: 30,
      barrierDismissible: false,
      title: "",
      content: Column(
        children: [
          Lottie.asset(
            'assets/json/success.json',
            repeat: false,
            frameRate: const FrameRate(120),
          ),
          const SizedBox(height: 10),
          Text(
            title ?? "Berhasil",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message ?? "",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: 140,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              elevation: 2,
              backgroundColor: CustomColor.secondaryColor,
            ),
            onPressed: onTap,
            child: Text(
              textButton ?? "Lanjutkan",
              style: GoogleFonts.inter(
                color: Theme.of(Get.context!).colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }


  static alertDialogCustomInfo({Function()? onTap, String? message, String? title, String? textButton, bool? moreThanOneButton, Color? colorPositiveButton}){
    return Get.defaultDialog(
      backgroundColor: CupertinoColors.lightBackgroundGray,
      radius: 10,
      barrierDismissible: false,
      title: "",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const Icon(CupertinoIcons.info, size: 60, color: Colors.black87),
            const SizedBox(height: 10),
            Text(title ?? "Berhasil", style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 5),
            Text(message ?? "Berhasil", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black54), textAlign: TextAlign.center)
          ],
        ),
      ),
      actions: [
        moreThanOneButton != null || moreThanOneButton == true ? SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.red
            ),
            onPressed: (){Get.back();},
            child: Text("Tidak", style: GoogleFonts.inter(color: Colors.white
            ))),
        ) : const SizedBox(),
        SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: colorPositiveButton ?? Colors.green
            ),
            onPressed: onTap,
            child: Text(textButton ?? "Lanjutkan", style: GoogleFonts.inter(color: Colors.white
            ))),
        ),
      ]
    );
  }


  static alertDialogCustomInfoButton({Function()? onTap, String? message, String? title, List<Widget>? widgets}){
    return Get.defaultDialog(
        backgroundColor: CupertinoColors.lightBackgroundGray,
        radius: 30,
        barrierDismissible: false,
        title: "",
        content: Column(
          children: [
            const Icon(CupertinoIcons.info, size: 60, color: Colors.black87),
            const SizedBox(height: 10),
            Text(title ?? "Berhasil", style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 5),
            Text(message ?? "Berhasil", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black54), textAlign: TextAlign.center)
          ],
        ),
        actions: widgets
    );
  }

  static alertError(BuildContext context, {Function()? onTap, String? message, String? title}){
    return Get.defaultDialog(
        backgroundColor: Theme.of(context).cardColor,
        radius: 30,
        barrierDismissible: false,
        title: "",
        content: Column(
          children: [
            Lottie.asset('assets/json/close.json', repeat: true,frameRate: const FrameRate(50)),
            const SizedBox(height: 10),
            Text(title ?? "Gagal", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 5),
            Text(message ?? "Galat", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.normal), textAlign: TextAlign.center)
          ],
        ),
        actions: [
          SizedBox(
            width: 120,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  elevation: 5,
                  backgroundColor: Colors.green
                ),
                onPressed: onTap ?? (){Get.back();},
                child: Text("Paham", style: GoogleFonts.inter(color: Colors.white
                ))),
          ),
        ]
    );
  }


  static alertWaiting(BuildContext context, {Function()? onTap, String? message, String? title}){
    return Get.defaultDialog(
        backgroundColor: Theme.of(context).cardColor,
        radius: 30,
        barrierDismissible: false,
        title: "",
        content: Column(
          children: [
            Lottie.asset('assets/json/waiting.json', repeat: true,frameRate: const FrameRate(50)),
            const SizedBox(height: 10),
            Text(title ?? "Waiting", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 5),
            Text(message ?? "Waiting", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.normal), textAlign: TextAlign.center)
          ],
        ),
        actions: [
          SizedBox(
            width: 120,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    elevation: 5,
                    backgroundColor: Colors.green
                ),
                onPressed: onTap ?? (){Get.back();},
                child: Text("Paham", style: GoogleFonts.inter(color: Colors.white
                ))),
          ),
        ]
    );
  }

  static whatsNew({String? versionApp, DateTime? time}){
    Get.defaultDialog(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        radius: 20,
        titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
        backgroundColor: Colors.white24,
        confirm: TextButton(
            onPressed: (){
              Get.back();
            },
            child: const Text("OK", style: TextStyle(color: Colors.white),)
        ),
        title: "What's New Version $versionApp\n${DateFormat('MMMM, dd yyyy').format(time!)}",
        titleStyle: const TextStyle(color: Colors.white, fontSize: 15),
        content: const Text("""
1. Menambah fitur pembuatan akun Demo pada tab Accounts
2. Halaman awal pembuaan akun Real, jika anda sudah memiliki akun Demo, maka anda akan diarahkan ke halaman awal untuk pembuatan akun Real.
2. Icon beranda baru pada halaman setelah login berhasil
3. Halaman Detail News ketika anda mengklik daftar news pada tab Home pada section News Sentiment
4. Halaman Detail Akun Real, Tap pada card akun real pada tab akun, maka anda akan diarahkan ke halaman detail tentang Real Akun,
5. Pop up what's new setiap ada update terbaru
""", style: TextStyle(color: Colors.white60, fontSize: 13))
    );
  }

  static void showMySnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message))
    );
  }
}