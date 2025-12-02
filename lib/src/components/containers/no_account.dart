import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/account_list/empty_account_state.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_0_password_meta.dart';

Widget noAccountDetected({String? title, String? description, IconData? icon}){
  final accountController = Get.find<AccountController>();
  final regolController = Get.find<RegolController>();
  final homeController = Get.find<HomeController>();
  RxBool isCreatingAccount = false.obs;

  return Obx(
    () => EmptyAccountState(
      isCreatingAccount: isCreatingAccount.value,
      onCreateAccount: () async {
        // 1️⃣ Tidak punya akun → auto buat demo
        if (!accountController.hasAccounts) {
          isCreatingAccount.value = true;
          final ok = await regolController.createDemoAccount();
          isCreatingAccount.value = false;
          if (ok) {
            AppSnackbar.success("Akun demo berhasil dibuat");
            await accountController.fetchAccountInfo();
          } else {
            AppSnackbar.error(regolController.responseMessage.value);
          }
          return;
        }
    
        // 2️⃣ Jika punya akun → cek pending
        final pendingOk = await homeController.getPendingAccount();
        if (!pendingOk) {
          AppSnackbar.error("Gagal mendapatkan status akun pending");
          return;
        }
    
        final pendingList = homeController.pendingModel.value?.response;
    
        // Tidak ada pending → langsung proses akun
        if (pendingList == null || pendingList.isEmpty) {
          await regolController.progressAccount();
          Get.to(() => CreateMT5PasswordPage());
          return;
        }
    
        // 3️⃣ Ada pending → cek status
        final status = pendingList.first.status;
        switch (status) {
          case "Registrasi":
            AppSnackbar.info("Akun masih dalam proses $status");
            break;
          case "Waiting":
            AppSnackbar.info("Akun masih dalam proses $status");
            break;
          case "Ditolak":
            Get.to(() => CreateMT5PasswordPage());
            break;
          case "Good Fund":
            break;
          case "Regol belum selesai":
            Get.to(() => CreateMT5PasswordPage());
            break;
          default:
            Get.to(() => CreateMT5PasswordPage());
            break;
        }
      },
    ),
  );
}