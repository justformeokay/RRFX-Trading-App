import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/views/accounts/deposit_new_account.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_0_password_meta.dart';

class PendingAccount extends StatefulWidget {
  const PendingAccount({super.key});

  @override
  State<PendingAccount> createState() => _PendingAccountState();
}

class _PendingAccountState extends State<PendingAccount> {
  HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      homeController.getPendingAccount().then((result){
        if(!result){}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => homeController.isLoading.value
        ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AntDesign.loading_3_quarters_outline, color: CustomColor.secondaryColor,),
                const SizedBox(height: 5),
                Text("Getting Pending...", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700))
              ],
            ),
          )
        : homeController.pendingModel.value?.response?.isEmpty == true
          ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HeroIcons.trash, color: CustomColor.secondaryColor),
                  SizedBox(height: 5),
                  Text("Tidak ada akun pending", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700))
                ],
              ),
            )
          : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            itemCount: homeController.pendingModel.value?.response?.length,
            itemBuilder: (context, index) {
              return Bounce(
                onTap: (){
                  switch(homeController.pendingModel.value?.response?[index].status){
                    case "Regol belum selesai": // Regol belum diselesaikan
                      Get.to(() => CreateMT5PasswordPage());
                      break;
                    case "Waiting":
                      CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data");
                      break;
                    case "Ditolak":
                      Get.to(() => CreateMT5PasswordPage());
                      break;
                    case "Register": // Sudah regol, menunggu admin accepting
                      CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data");
                      break;
                    case "Deposit New Account": // Sesudah di acc WPB, menunggu nasabah deposit
                      Get.to(() => const DepositNewAccount());
                      break;
                    case "Waiting Deposit": // Deposit nasabah dalam proses verifikasi oleh admin
                      CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun Anda sedang menunggu konfirmasi dari admin.");
                      break;
                    case "Good Fund": // Pemberian password dan username meta melalui email
                      break;
                    case "Active":
                      break;
                    default:
                      break;
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: CustomColor.secondaryColor, width: 0.6),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(homeController.pendingModel.value?.response?[index].type ?? "-", style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: CustomColor.secondaryColor)),
                        ],
                      ),
                      const Divider(color: CustomColor.secondaryColor),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Product", style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: CustomColor.secondaryColor)),
                          Flexible(child: Text(homeController.pendingModel.value?.response?[index].product ?? "-", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: CustomColor.secondaryColor))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Currency", style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: CustomColor.secondaryColor)),
                          Flexible(child: Text(homeController.pendingModel.value?.response?[index].currency ?? "-", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: CustomColor.secondaryColor))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Rate", style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: CustomColor.secondaryColor)),
                          Flexible(child: Text(homeController.pendingModel.value?.response?[index].rate ?? "-", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: CustomColor.secondaryColor))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status", style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: CustomColor.secondaryColor)),
                          Flexible(child: Text(homeController.pendingModel.value?.response?[index].status ?? "-", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: CustomColor.secondaryColor))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Date", style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: CustomColor.secondaryColor)),
                          Flexible(child: Text(homeController.pendingModel.value?.response?[index].dateCreated != null ? DateFormat("EEEE, dd MMM yyyy").format(DateTime.parse(homeController.pendingModel.value!.response![index].dateCreated!)) : "-", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: CustomColor.secondaryColor))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Time", style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: CustomColor.secondaryColor)),
                          Flexible(child: Text(homeController.pendingModel.value?.response?[index].dateCreated != null ? DateFormat().add_jms().format(DateTime.parse(homeController.pendingModel.value!.response![index].dateCreated!)) : "-", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: CustomColor.secondaryColor))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}
