import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
import 'package:rrfx/src/helpers/formatters/masking_email.dart';
import 'package:rrfx/src/views/authentications/success_verified_otp.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxString phoneCode = "".obs;
  RxString number = "".obs;
  RxString otpChannel = "whatsapp".obs; // 'email' or 'whatsapp'
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // appBar: AppBar(
        //   elevation: 0,
        //   forceMaterialTransparency: true,
        //   leadingWidth: 200,
        //   leading: Row(
        //     children: [
        //       IconButton(
        //         icon: Icon(
        //           CupertinoIcons.back,
        //           color: Theme.of(context).textTheme.titleLarge?.color,
        //         ),
        //         onPressed: () => Get.offAll(() => MainpageWithoutLogin()),
        //       ),
        //       Text("Kembali Login", style: GoogleFonts.inter(
        //         fontSize: 14,
        //         fontWeight: FontWeight.w600,
        //         color: Theme.of(context).textTheme.titleLarge?.color,
        //       )),
        //     ],
        //   ),
        //   systemOverlayStyle: SystemUiOverlayStyle(
        //     statusBarColor: Colors.transparent,
        //     statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        //     statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        //   ),
        // ),
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
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: CustomColor.secondaryColor,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      "Akun Anda",
                      style: GoogleFonts.inter(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Obx(
                      () {
                        return Text(
                          "Kode OTP telah dikirim ke $otpChannel anda. Jika Anda tidak menerima kode OTP, pilih cara dibawah untuk menerima kode OTP dan verifikasi akun Anda",
                          style: TextStyle(
                            color: CustomColor.textThemeLightSoftColor,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        );
                      }
                    ),

                    // ===== CHANNEL SELECTOR =====
                    Obx(() {
                      if (authController.otpResendCountdown.value <= 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pilih Metode Pengiriman",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
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
                                      otpChannel.value = "whatsapp";
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28.0),
                          ],
                        );
                      } else {
                        return const SizedBox(height: 28.0);
                      }
                    }),

                    // ===== DESTINATION INFO =====
                    Obx(() {
                      final email = maskEmail(homeController.profileModel.value?.email ?? 'example@email.com');
                      final displayText = otpChannel.value == "email"
                          ? "Kami akan mengirim kode OTP ke:\n$email"
                          : "Kami akan mengirim kode OTP ke:\nNomor WhatsApp Anda";

                      if(authController.otpResendCountdown.value > 0) {
                        return const SizedBox();
                      }
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
                        maxLength: 4,
                        fieldName: "Kode OTP",
                        controller: otpController,
                        hintText: "Masukkan 6 digit",
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // ===== RESEND TIMER =====
                    Obx(() => ResendOtpText(
                      isResendAvailable: authController.otpResendCountdown.value < 1,
                      secondsRemaining: authController.otpResendCountdown.value,
                      onResend: () {
                        Get.log("🔄 [OTP_PAGE] User clicked Resend OTP");
                        Get.log("📱 [OTP_PAGE] Selected channel: ${otpChannel.value}");
                        
                        authController.resendOTP(type: otpChannel.value).then((result) {
                          Get.log("📥 [OTP_PAGE] Resend OTP result: $result");
                          Get.log("💬 [OTP_PAGE] Response message: ${authController.responseMessage.value}");
                          
                          if (result) {
                            Get.log("✅ [OTP_PAGE] Resend OTP SUCCESS - Starting countdown from server value");
                            // Use countdown value from server (otp_expired_in), already set in controller
                            _showModernResendSuccessDialog(
                              context,
                              otpChannel.value,
                              60,
                            );
                          } else {
                            Get.log("❌ [OTP_PAGE] Resend OTP FAILED - Showing error");
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: authController.responseMessage.value,
                              type: SnackBarType.error,
                            );
                          }
                        }).catchError((error) {
                          Get.log("💥 [OTP_PAGE] Resend OTP EXCEPTION: $error");
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Terjadi kesalahan saat mengirim ulang OTP",
                            type: SnackBarType.error,
                          );
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
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40.0),
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
                            Get.offAll(() => const SuccessVerifiedOtpPage());
                            // Get.offAll(() => const VerificationAccountPage());
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

  // ===== MODERN RESEND SUCCESS DIALOG =====
  void _showModernResendSuccessDialog(BuildContext context, String channel, int countdown) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final channelName = channel == 'email' ? 'Email' : 'WhatsApp';
    final channelIcon = channel == 'email' ? Iconsax.direct_inbox_bold : Bootstrap.whatsapp;
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Animation Icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CustomColor.secondaryColor.withOpacity(0.2),
                                CustomColor.secondaryColor.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 50,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    "Berhasil Dikirim! 🎉",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Channel Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: CustomColor.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: CustomColor.secondaryColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          channelIcon,
                          size: 16,
                          color: CustomColor.secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "via $channelName",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "Kode OTP baru telah dikirim ke $channelName Anda. Silakan periksa dan masukkan kode verifikasi yang baru.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: CustomColor.textThemeLightSoftColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Countdown Info
                  if (countdown > 0) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Berlaku selama ${_formatCountdown(countdown)}",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 28),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Mengerti",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Helper to format countdown
  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes menit $secs detik';
    }
    return '$secs detik';
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

