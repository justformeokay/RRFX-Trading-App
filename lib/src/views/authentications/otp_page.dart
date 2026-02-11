import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/textfields/label_textfield.dart';
import 'package:rrfx/src/components/textfields/otp_textfield.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/resend_otp_controller.dart';
import 'package:rrfx/src/helpers/formatters/masking_email.dart';
import 'package:rrfx/src/views/authentications/verification_account_page.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final OtpTimerController otpTimerController = Get.put(OtpTimerController());
  RxBool isLoading = false.obs;
  RxString phoneCode = "".obs;
  RxString number = "".obs;
  RxString otpChannel = "email".obs; // 'email' or 'whatsapp'
  AuthController authController = Get.find();
  TextEditingController otpController = TextEditingController();
  HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    otpTimerController.startTimer(duration: 270);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          leadingWidth: 200,
          leading: Row(
            children: [
              IconButton(
                icon: Icon(
                  CupertinoIcons.back,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                onPressed: () => Get.offAll(() => MainpageWithoutLogin()),
              ),
              Text("Kembali Login", style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              )),
            ],
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Title
                    Text(
                      "Verifikasi",
                      style: GoogleFonts.inter(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        color: CustomColor.secondaryColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      "Akun Anda",
                      style: GoogleFonts.inter(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Obx(
                      () {
                        final email = maskEmail(homeController.profileModel.value?.email ?? 'example@email.com');
                        return Text(
                          "Kode OTP telah dikirim ke alamat email $email. Jika Anda tidak menerima kode OTP, pilih cara dibawah untuk menerima kode OTP dan verifikasi akun Anda",
                          style: TextStyle(
                            color: CustomColor.textThemeLightSoftColor,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 32.0),

                    // ===== CHANNEL SELECTOR =====
                    Text(
                      "Pilih Metode Pengiriman",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                      children: [
                        // Email Option
                        Expanded(
                          child: _buildChannelButton(
                            context: context,
                            icon: Iconsax.direct_inbox_outline,
                            activeIcon: Iconsax.direct_inbox_bold,
                            title: "Email",
                            value: "email",
                            isSelected: otpChannel.value == "email",
                            onTap: () {
                              otpChannel.value = "email";
                              otpTimerController.resetTimer(300);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // WhatsApp Option
                        Expanded(
                          child: _buildChannelButton(
                            context: context,
                            icon: Bootstrap.whatsapp,
                            activeIcon: Bootstrap.whatsapp,
                            title: "WhatsApp",
                            value: "whatsapp",
                            isSelected: otpChannel.value == "whatsapp",
                            onTap: () {
                              _showWhatsAppComingSoonDialog(context);
                            },
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 28.0),

                    // ===== DESTINATION INFO =====
                    Obx(() {
                      final email = maskEmail(homeController.profileModel.value?.email ?? 'example@email.com');
                      final displayText = otpChannel.value == "email"
                          ? "Kami akan mengirim kode OTP ke:\n$email"
                          : "Kami akan mengirim kode OTP ke:\nNomor WhatsApp Anda";

                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: CustomColor.secondaryColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: CustomColor.secondaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  otpChannel.value == "email"
                                      ? Iconsax.direct_inbox_outline
                                      : Bootstrap.whatsapp,
                                  color: CustomColor.secondaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  displayText,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 28.0),

                    // ===== OTP INPUT =====
                    LabelTextField.labelName(
                      label: "Kode OTP",
                      required: true,
                      child: OTPTextField(
                        requiredField: true,
                        labelText: "Kode OTP",
                        fieldName: "Kode OTP",
                        controller: otpController,
                        hintText: "Masukkan 6 digit",
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // ===== RESEND TIMER =====
                    Obx(() => ResendOtpText(
                      isResendAvailable: otpTimerController.isFinished,
                      secondsRemaining: otpTimerController.seconds.value,
                      onResend: () {
                        authController.resendOTP().then((result) {
                          if (result) {
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: authController.responseMessage.value,
                              type: SnackBarType.success,
                            );
                            otpTimerController.resetTimer(300);
                          } else {
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: authController.responseMessage.value,
                              type: SnackBarType.error,
                            );
                          }
                        });
                      },
                    )),

                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Obx(
            () => DefaultButton.defaultElevatedButton(
              onPressed: authController.isLoading.value
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        authController.confirmOTP(otp: otpController.text).then((result) {
                          if (result) {
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: authController.responseMessage.value,
                              type: SnackBarType.success,
                            );
                            Get.offAll(() => const VerificationAccountPage());
                          } else {
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: authController.responseMessage.value,
                              type: SnackBarType.error,
                            );
                          }
                        });
                      }
                    },
              title: authController.isLoading.value ? "Processing..." : "Verifikasi OTP",
            ),
          ),
        ),
      ),
    );
  }

  // ===== CHANNEL BUTTON WIDGET =====
  Widget _buildChannelButton({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? CustomColor.secondaryColor.withOpacity(0.1)
            : isDark
                ? Colors.grey[900]
                : Colors.grey[100],
        border: Border.all(
          color: isSelected
              ? CustomColor.secondaryColor
              : isDark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: isSelected ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CustomColor.secondaryColor.withOpacity(0.15)
                          : isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected
                          ? CustomColor.secondaryColor
                          : isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? CustomColor.secondaryColor
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== WHATSAPP COMING SOON DIALOG =====
  void _showWhatsAppComingSoonDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomColor.secondaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Bootstrap.whatsapp,
                    size: 40,
                    color: CustomColor.secondaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  "WhatsApp OTP",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle - Coming Soon Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Segera Hadir",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  "Fitur pengiriman OTP melalui WhatsApp sedang kami kembangkan. Gunakan Email untuk saat ini, dan kami akan memberitahu Anda ketika fitur ini tersedia.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: CustomColor.textThemeLightSoftColor,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // CTA Buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: Text(
                          "Tutup",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Use Email Instead
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Switch to Email and close dialog
                          otpChannel.value = "email";
                          otpTimerController.resetTimer(300);
                          Get.back();
                        },
                        child: Text(
                          "Gunakan Email",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class ResendOtpText extends StatelessWidget {
  final VoidCallback onResend;
  final bool isResendAvailable;
  final int secondsRemaining;

  const ResendOtpText({
    super.key,
    required this.onResend,
    required this.isResendAvailable,
    this.secondsRemaining = 0,
  });

  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')} detik';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CustomColor.secondaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            children: [
              const TextSpan(text: "Tidak menerima kode OTP? "),
              isResendAvailable
                  ? TextSpan(
                      text: "Kirim Ulang",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: CustomColor.secondaryColor,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = onResend,
                    )
                  : TextSpan(
                      text: "Tunggu ${_formatTimer(secondsRemaining)}",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CustomColor.textThemeLightSoftColor,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

