import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/controllers/trading_account_controller.dart';
import 'package:rrfx/src/helpers/formatters/masking_email.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/index.dart';
import 'package:rrfx/src/views/authentications/manage_passcode_page.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:rrfx/src/views/settings/daftar_bank_saya.dart';
import 'package:rrfx/src/views/settings/delete_account.dart';
import 'package:rrfx/src/views/settings/documents/views/document_list_page.dart';
import 'package:rrfx/src/views/settings/invite_link.dart';
import 'package:rrfx/src/views/settings/request_ib_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/helpers/handlers/image_picker.dart';
import 'package:rrfx/src/views/settings/deposit_withdrawal_history.dart';
import 'package:rrfx/src/views/settings/edit_profile.dart';
import 'package:rrfx/src/views/settings/faq.dart';
import 'package:rrfx/src/views/settings/image_viewer_page.dart';
import 'package:rrfx/src/views/settings/ticket_rooms.dart';
import 'package:rrfx/src/views/trade/deposit.dart';
import 'package:rrfx/src/views/trade/internal_transfer.dart';
import 'package:rrfx/src/views/trade/withdrawal.dart';
import 'about_app.dart';
import 'components/settings_components.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  HomeController homeController = Get.find();
  AuthController authController = Get.find();
  RxString selectedImage = "".obs;
  UserController userController = Get.put(UserController());
  final _accountController = Get.put(AccountController());
  TradingController tradingController = Get.put(TradingController());
  TradingAccountController tradingAccountController = Get.find();
  RxBool haveRealAccount = false.obs;
  RxBool isLoading = false.obs;

  // Contoh fungsi baru (atau modifikasi yang sudah ada)
  String buildCacheBustedImageUrl(String? url, int version) {
      if (url == null) return '';
      String fullUrl = buildFullImageUrl(url); 
      final uri = Uri.parse(fullUrl);
      final newQueryParameters = {
        ...uri.queryParameters,
        'v': version.toString(), 
      };
      final newUri = uri.replace(queryParameters: newQueryParameters);
      return newUri.toString();
  }


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      isLoading.value = true;
      homeController.profile();
      _accountController.fetchAccountInfo().then((resultAccount){
        isLoading.value = false;
        if(_accountController.allAccounts.isEmpty){
          haveRealAccount.value = false;
          return;
        }
        if(_accountController.allAccounts.any((account) => account.type == 'real')){
          haveRealAccount.value = true;
        }else{
          haveRealAccount.value = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Settings",
        actions: [
          CupertinoButton(
            onPressed: () async {
              userController.getProfile();
              CustomAlert.alertDialogCustomInfo(
                message: "Apakah anda yakin keluar dari aplikasi?",
                moreThanOneButton: true,
                onTap: () async {
                  Get.log("🔴 [LOGOUT] User confirmed logout");
                  
                  // Clear SharedPreferences
                  Get.log("🗑️ [LOGOUT] Clearing SharedPreferences...");
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove('accessToken');
                  prefs.remove('refreshToken');
                  prefs.remove('loggedIn');
                  prefs.remove('accountAccountIndex');
                  prefs.remove('selectedLogin');
                  prefs.remove('selectedType');
                  prefs.remove('selectedCurrency');
                  prefs.remove('selectedLeverage');
                  Get.log("✅ [LOGOUT] SharedPreferences cleared");
                  
                  // Clear GetStorage (includes favorite symbols) - but preserve passcode
                  Get.log("🗑️ [LOGOUT] Clearing GetStorage...");
                  final storage = GetStorage();
                  
                  // Save passcode before erasing storage
                  final savedPasscodeData = storage.read('app_passcode');
                  Get.log("💾 [LOGOUT] Saving passcode data before erase: $savedPasscodeData");
                  
                  await storage.erase();
                  
                  // Restore passcode after erasing storage
                  if (savedPasscodeData != null) {
                    await storage.write('app_passcode', savedPasscodeData);
                    Get.log("✅ [LOGOUT] Passcode restored after erase");
                  }
                  Get.log("✅ [LOGOUT] GetStorage cleared (passcode preserved)");
                  
                  // Clear controllers
                  Get.log("🗑️ [LOGOUT] Disposing controllers...");
                  Get.log("   - Clearing AccountController default account");
                  _accountController.clearDefaultAccount();
                  Get.log("   - Resetting AccountController state");
                  _accountController.resetAccountsState();
                  Get.log("   - Deleting AccountController");
                  Get.delete<AccountController>();
                  Get.log("   - Deleting TradingAccountController");
                  Get.delete<TradingAccountController>();
                  Get.log("   - Deleting TradingController");
                  Get.delete<TradingController>();
                  Get.log("   - Deleting UserController");
                  Get.delete<UserController>();
                  Get.log("   - Deleting HomeController (force: true for permanent)");
                  Get.delete<HomeController>(force: true);
                  Get.log("✅ [LOGOUT] All controllers deleted");
                  
                  // Navigate to login
                  Get.log("🚀 [LOGOUT] Navigating to MainpageWithoutLogin");
                  Get.offAll(() => const MainpageWithoutLogin());
                },
                title: "Keluar",
                textButton: "Ya"
              );
            },
            child: Icon(Iconsax.logout_1_outline, color: CustomColor.secondaryColor),
          )
        ]
      ),
      body: Obx(
        () => RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh: isLoading.value ? () async {} : () async {
            haveRealAccount.value = false;
            await _accountController.fetchAccountInfo().then((result){
              if(_accountController.allAccounts.any((account) => account.type == 'real')){
                haveRealAccount.value = true;
              }else{
                haveRealAccount.value = false;
              }
            });
            await homeController.profile();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Obx(() {
                  final String? photoUrl = homeController.profileModel.value?.urlPhoto;
                  return Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageViewerPage(
                                    imageUrl: buildFullImageUrl(
                                      photoUrl,
                                      userController.photoVersion.value,
                                    ),
                                    title: '${homeController.profileModel.value?.name}\'s Profile Picture',
                                  ),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              key: ValueKey(userController.photoVersion.value),
                              imageUrl: buildFullImageUrl(
                                photoUrl,
                                userController.photoVersion.value,
                              ),
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 40,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                                child: CircularProgressIndicator(strokeWidth: 2, color: CustomColor.secondaryColor),
                              ),
                              errorWidget: (context, url, error) => const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final pickedImage =
                                    await CustomImagePicker.pickImageFromCameraAndReturnUrl();
        
                                if (pickedImage.isNotEmpty) {
                                  final result = await userController.updateAvatar(
                                    urlImage: pickedImage,
                                  );
                                  if (result) {
                                    userController.photoVersion.value++;
                                    await homeController.profile();
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: CustomColor.secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.camera_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeController.profileModel.value?.name ?? 'Unknown Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              maskEmail(homeController.profileModel.value?.email ?? ''),
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.to(() => const EditProfile()),
                        icon: const Icon(Iconsax.edit_outline),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 20),
                // Frequently Opened
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Frequently Opened", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Obx(
                      () => SettingComponents.storageCard(
                        context,
                        "Withdrawal",
                        enabled: isLoading.value || !haveRealAccount.value ? false : true,
                        Iconsax.arrow_up_2_outline,
                        onTap: (){
                          if(isLoading.value){
                            return;
                          }
                          if(!haveRealAccount.value){
                            showNoRealAccountPopup();
                            return;
                          }
                          Get.to(() => const Withdrawal());
                        }
                      ),
                    ),
                    Obx(
                      () => SettingComponents.storageCard(
                        context,
                        enabled: isLoading.value || !haveRealAccount.value ? false : true,
                        "Deposit",
                        Iconsax.arrow_down_1_outline,
                        onTap: (){
                          if(isLoading.value){
                            return;
                          }
                          if(!haveRealAccount.value){
                            showNoRealAccountPopup();
                            return;
                          }
                          Get.to(() => const Deposit());
                        }
                        ),
                    ),
                    Obx(
                      () => SettingComponents.storageCard(
                        context,
                        "Transfer",
                        enabled: isLoading.value || !haveRealAccount.value ? false : true,
                        Iconsax.transaction_minus_outline,
                        onTap: () {
                          if(isLoading.value){
                            return;
                          }
                          if(!haveRealAccount.value){
                            showNoRealAccountPopup();
                            return;
                          }
                          if(_accountController.allAccounts.where((account) => account.type == 'real').length < 2){
                            AppSnackbar.error("Menu Internal Transfer hanya bisa dilakukan jika anda memiliki minimal 2 akun Real");
                            return;
                          }else{
                            Get.to(() => const InternalTransfer());
                          }
                        },
                      ),
                    ),
                    Obx(
                      () => SettingComponents.storageCard(
                        context,
                        enabled: isLoading.value || !haveRealAccount.value ? false : true,
                        "Documents",
                        Iconsax.document_outline,
                        onTap: () {
                          if(isLoading.value){
                            return;
                          }
                          if(!haveRealAccount.value){
                            showNoRealAccountPopup();
                            return;
                          }
                          if(_accountController.selectedAccount.value == null) {
                            AppSnackbar.error("Silakan pilih akun trading terlebih dahulu.");
                            return;
                          }
                          if(_accountController.selectedAccount.value!.type == "demo") {
                            showRealAccountOnlyPopup(context);
                            return;
                          }
                          Get.to(() => DocumentListPage(loginID: _accountController.selectedAccount.value?.login ?? ''));
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                
                // Security Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Keamanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12),
                SettingComponents.listTileItem(context, "Kelola Passcode", "Ubah passcode atau atur biometric", Iconsax.lock_outline, onTap: () async {
                  Get.to(() => const ManagePasscodePage());
                }),
                SizedBox(height: 30),
          
                // All Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Others", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12),
                SettingComponents.listTileItem(context, "Daftar Akun Trading Saya", "Informasi mengenai Daftar Akun Trading saya", Iconsax.wallet_outline, onTap: () async {
                  Get.to(() => const Accounts());
                }),
                SettingComponents.listTileItem(context, "Bank Saya", "Informasi mengenai bank saya", Iconsax.money_2_outline, onTap: () async {
                  Get.to(() => const DaftarBankSaya());
                }),
                Obx(
                  () => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Iconsax.moon_outline, color: Theme.of(context).colorScheme.onSurface),
                    subtitle: Text(
                      "Ubah tema ke Mode Gelap",
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    title: Text("Mode Gelap", style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),),
                    trailing: Switch(
                      activeColor: CustomColor.secondaryColor,
                      value: themeController.isDark.value,
                      onChanged: (value) {
                        themeController.toggleTheme(value);
                      },
                    ),
                  )
                ),
                Obx(
                  () => SettingComponents.listTileItem(
                    context,
                    enabled: isLoading.value || !haveRealAccount.value ? false : true,
                    "Riwayat Deposit Withdrawal", 
                    "Semua riwayat deposit akun trading anda", 
                    Iconsax.note_outline, 
                    onTap: haveRealAccount.value ? () => Get.to(() => const DepositWithdrawalHistory()) : () {
                      showNoRealAccountPopup();
                    }),
                ),
                SettingComponents.listTileItem(context, "Tickets", "Help your problem", Iconsax.headphone_outline, onTap: () async {
                  Get.to(() => const TicketRooms());
                }),
                SettingComponents.listTileItem(context, "FAQ", "All Frequently Asking Question", Iconsax.quote_down_square_outline, onTap: (){
                  Get.to(() => const Faq());
                }),
                SettingComponents.listTileItem(context, "About", "Information about this App", Iconsax.info_circle_outline, onTap: (){
                  Get.to(() => const AboutApp());
                }),
                SettingComponents.listTileItem(context, "Invite Link", "Ajak rekan anda bergabung dengan RRFX", Iconsax.link_circle_outline, onTap: (){
                  Get.to(() => const InviteLink());
                }),
                SettingComponents.listTileItem(context, "Request IB", "Mari bergabung sebagai Introducing Broker",
                  enabled: false,
                  Iconsax.user_add_outline,
                  onTap: () {
                    Get.to(() => const RequestIBPage());
                  },
                ),
                SettingComponents.listTileItem(context, "Hapus Akun", "Hapus Akun Saya ", enabled: true, Iconsax.trash_outline, onTap: (){
                  Get.to(() => const DeleteAccountPage());
                  // Get.to(() => const SIDRegistrationPage());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String buildFullImageUrl(String? url, [int? version]) {
    if (url == null || url.isEmpty) return "";
    // pastikan tidak tambah ts setiap rebuild
    if (url.startsWith("http")) {
      return version != null ? "$url?v=$version" : url;
    }
    return version != null ? "${GlobalVariable.mainURL}$url?v=$version" : "${GlobalVariable.mainURL}$url";
    }
}