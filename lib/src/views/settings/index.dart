import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'package:rrfx/src/views/resources/resources_center.dart';
import 'package:rrfx/src/views/settings/daftar_bank_saya.dart';
import 'package:rrfx/src/views/settings/documents/views/document_list_page.dart';
import 'package:rrfx/src/views/settings/invite_link.dart';
import 'package:rrfx/src/views/settings/request_ib_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
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
    Future.delayed(Duration.zero, () {
      isLoading.value = true;
      homeController.profile();
      _accountController.fetchAccountInfo().then((resultAccount) {
        isLoading.value = false;
        if (_accountController.allAccounts.isEmpty) {
          haveRealAccount.value = false;
          return;
        }
        if (_accountController.allAccounts.any(
          (account) => account.type == 'real',
        )) {
          haveRealAccount.value = true;
        } else {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: kIsWeb ? 500 : double.infinity,
          ),
          child: Obx(
        () => RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh:
              isLoading.value
                  ? () async {}
                  : () async {
                    haveRealAccount.value = false;
                    await _accountController.fetchAccountInfo(forceRefresh: true).then((result) {
                      if (_accountController.allAccounts.any(
                        (account) => account.type == 'real',
                      )) {
                        haveRealAccount.value = true;
                      } else {
                        haveRealAccount.value = false;
                      }
                    });
                    await homeController.profile(forceRefresh: true);
                  },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── PROFILE HEADER ───
              SliverToBoxAdapter(child: _buildProfileHeader(context, isDark, colorScheme)),

              // ─── QUICK ACTIONS ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildQuickActions(context, isDark, colorScheme),
                ),
              ),

              // ─── SECURITY SECTION ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildSectionCard(
                    context, isDark, colorScheme,
                    title: "Security",
                    icon: Iconsax.shield_tick_outline,
                    items: [
                      _MenuItemData(
                        icon: Iconsax.lock_outline,
                        iconColor: Colors.blue,
                        title: "Manage Passcode",
                        subtitle: "Change passcode or set biometric",
                        onTap: () => Get.to(() => const ManagePasscodePage()),
                      ),
                      _MenuItemData(
                        icon: Iconsax.moon_outline,
                        iconColor: Colors.deepPurple,
                        title: "Dark Mode",
                        subtitle: "Switch to dark theme",
                        trailing: Obx(() => CupertinoSwitch(
                          activeTrackColor: CustomColor.secondaryColor,
                          value: themeController.isDark.value,
                          onChanged: (value) => themeController.toggleTheme(value),
                        )),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── DEVELOPER SECTION ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildSectionCard(
                    context, isDark, colorScheme,
                    title: "Developer Options",
                    icon: Iconsax.shield_tick_outline,
                    items: [
                      _MenuItemData(
                        icon: Iconsax.lock_outline,
                        iconColor: Colors.blue,
                        title: "Base URL",
                        subtitle: "Change the base URL for API requests",
                        onTap: () => Get.to(() => const ManageBaseUrlPage()),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── ACCOUNT & FINANCE ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildSectionCard(
                    context, isDark, colorScheme,
                    title: "Account & Finance",
                    icon: Iconsax.wallet_outline,
                    items: [
                      _MenuItemData(
                        icon: Iconsax.wallet_outline,
                        iconColor: CustomColor.secondaryColor,
                        title: "Trading Accounts",
                        subtitle: "View all trading accounts",
                        onTap: () => Get.to(() => const Accounts()),
                      ),
                      _MenuItemData(
                        icon: Iconsax.money_2_outline,
                        iconColor: Colors.green,
                        title: "My Banks",
                        subtitle: "Manage your bank accounts",
                        onTap: () => Get.to(() => const DaftarBankSaya()),
                      ),
                      _MenuItemData(
                        icon: Iconsax.note_outline,
                        iconColor: Colors.teal,
                        title: "Deposit & Withdrawal History",
                        subtitle: "All transaction history",
                        enabled: !isLoading.value && haveRealAccount.value,
                        onTap: haveRealAccount.value
                            ? () => Get.to(() => const DepositWithdrawalHistory())
                            : () => showNoRealAccountPopup(),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── SUPPORT & RESOURCES ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildSectionCard(
                    context, isDark, colorScheme,
                    title: "Support & Resources",
                    icon: Iconsax.message_question_outline,
                    items: [
                      _MenuItemData(
                        icon: Iconsax.book_outline,
                        iconColor: Colors.indigo,
                        title: "Resource Center",
                        subtitle: "Trading info, products, education",
                        onTap: () => Get.to(() => const ResourcesCenter()),
                      ),
                      _MenuItemData(
                        icon: Iconsax.headphone_outline,
                        iconColor: Colors.orange,
                        title: "Support Tickets",
                        subtitle: "Get help with your issues",
                        onTap: () => Get.to(() => const TicketRooms()),
                      ),
                      _MenuItemData(
                        icon: Iconsax.quote_down_square_outline,
                        iconColor: Colors.cyan,
                        title: "FAQ",
                        subtitle: "Frequently asked questions",
                        onTap: () => Get.to(() => const Faq()),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── MORE ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildSectionCard(
                    context, isDark, colorScheme,
                    title: "More",
                    icon: Iconsax.more_circle_outline,
                    items: [
                      _MenuItemData(
                        icon: Iconsax.link_circle_outline,
                        iconColor: Colors.purple,
                        title: "Invite Friends",
                        subtitle: "Share your referral link",
                        onTap: () => Get.to(() => const InviteLink()),
                      ),
                      _MenuItemData(
                        icon: Iconsax.user_add_outline,
                        iconColor: Colors.blueGrey,
                        title: "Request IB",
                        subtitle: "Become an Introducing Broker",
                        enabled: false,
                        onTap: () => Get.to(() => const RequestIBPage()),
                      ),
                      _MenuItemData(
                        icon: Iconsax.info_circle_outline,
                        iconColor: Colors.grey,
                        title: "About",
                        subtitle: "App information & version",
                        onTap: () => Get.to(() => const AboutApp()),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── DANGER ZONE ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildDangerSection(context, isDark, colorScheme),
                ),
              ),

              // ─── LOGOUT BUTTON ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: _buildLogoutButton(context, isDark),
                ),
              ),

              // ─── BOTTOM SPACING ───
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PROFILE HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildProfileHeader(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [CustomColor.secondaryColor, const Color(0xFFD4A020)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              // Top row with title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Settings",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  // Notifications icon (optional, for visual balance)
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),

              // Profile card
              Obx(() {
                final String? photoUrl =
                    homeController.profileModel.value?.urlPhoto;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
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
                                    title:
                                        '${homeController.profileModel.value?.name}\'s Profile Picture',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 2.5,
                                ),
                              ),
                              child: CachedNetworkImage(
                                key: ValueKey(userController.photoVersion.value),
                                imageUrl: buildFullImageUrl(
                                  photoUrl,
                                  userController.photoVersion.value,
                                ),
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundImage: imageProvider,
                                    ),
                                placeholder: (context, url) => const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.white24,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
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
                                      urlImage: pickedImage);
                                  if (result) {
                                    userController.photoVersion.value++;
                                    await homeController.profile(forceRefresh: true);
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Iconsax.camera_outline,
                                  color: CustomColor.secondaryColor,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Name & email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeController.profileModel.value?.name ?? 'Unknown Name',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              maskEmail(
                                homeController.profileModel.value?.email ?? '',
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.75),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Edit button
                      GestureDetector(
                        onTap: () => Get.to(() => const EditProfile()),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Iconsax.edit_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // QUICK ACTIONS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildQuickActions(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                context, isDark,
                icon: Iconsax.arrow_down_1_outline,
                label: "Deposit",
                color: Colors.green,
                enabled: !isLoading.value && haveRealAccount.value,
                onTap: () {
                  if (isLoading.value) return;
                  if (!haveRealAccount.value) {
                    showNoRealAccountPopup();
                    return;
                  }
                  Get.to(() => const Deposit());
                },
              ),
              _buildQuickActionItem(
                context, isDark,
                icon: Iconsax.arrow_up_2_outline,
                label: "Withdraw",
                color: Colors.red,
                enabled: !isLoading.value && haveRealAccount.value,
                onTap: () {
                  if (isLoading.value) return;
                  if (!haveRealAccount.value) {
                    showNoRealAccountPopup();
                    return;
                  }
                  Get.to(() => const Withdrawal());
                },
              ),
              _buildQuickActionItem(
                context, isDark,
                icon: Iconsax.transaction_minus_outline,
                label: "Transfer",
                color: Colors.blue,
                enabled: !isLoading.value && haveRealAccount.value,
                onTap: () {
                  if (isLoading.value) return;
                  if (!haveRealAccount.value) {
                    showNoRealAccountPopup();
                    return;
                  }
                  if (_accountController.allAccounts
                          .where((account) => account.type == 'real')
                          .length < 2) {
                    AppSnackbar.error(
                      "Menu Internal Transfer hanya bisa dilakukan jika anda memiliki minimal 2 akun Real",
                    );
                    return;
                  }
                  Get.to(() => const InternalTransfer());
                },
              ),
              _buildQuickActionItem(
                context, isDark,
                icon: Iconsax.document_outline,
                label: "Documents",
                color: Colors.orange,
                enabled: !isLoading.value && haveRealAccount.value,
                onTap: () {
                  if (isLoading.value) return;
                  if (!haveRealAccount.value) {
                    showNoRealAccountPopup();
                    return;
                  }
                  if (_accountController.selectedAccount.value == null) {
                    AppSnackbar.error(
                      "Silakan pilih akun trading terlebih dahulu.",
                    );
                    return;
                  }
                  if (_accountController.selectedAccount.value!.type == "demo") {
                    showRealAccountOnlyPopup(context);
                    return;
                  }
                  Get.to(
                    () => DocumentListPage(
                      loginID: _accountController.selectedAccount.value?.login ?? '',
                    ),
                  );
                },
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, bool isDark, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION CARD (Grouped menu items)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSectionCard(
    BuildContext context, bool isDark, ColorScheme colorScheme, {
    required String title,
    required IconData icon,
    required List<_MenuItemData> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: CustomColor.secondaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return _buildMenuTile(
              context, isDark, colorScheme,
              item: item,
              showDivider: !isLast,
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, bool isDark, ColorScheme colorScheme, {
    required _MenuItemData item,
    bool showDivider = true,
  }) {
    final isEnabled = item.enabled;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.45,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? item.onTap : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.iconColor.withOpacity(isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: isEnabled
                            ? item.iconColor
                            : colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trailing
                    if (item.trailing != null)
                      item.trailing!
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 70, right: 16),
              child: Divider(
                height: 1,
                color: colorScheme.onSurface.withOpacity(0.06),
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DANGER SECTION
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDangerSection(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            CustomAlert.alertDialogCustomInfo(
              message: "Fitur ini masih dalam tahap pengembangan. Terima kasih atas kesabaran Anda!",
              title: "Coming Soon",
              onTap: () {
                Navigator.of(context).pop();
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.trash_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delete Account",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Permanently delete your account",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.red.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Colors.red.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOGOUT BUTTON
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: Icon(
          Iconsax.logout_1_outline,
          size: 20,
          color: Colors.red.shade400,
        ),
        label: Text(
          "Log Out",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.red.shade400,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withOpacity(0.3), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          CustomAlert.alertDialogCustomInfo(
            message: "Apakah anda yakin keluar dari aplikasi?",
            moreThanOneButton: true,
            onTap: () async {
              Get.log("🔴 [LOGOUT] User confirmed logout");

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

              Get.log("🗑️ [LOGOUT] Clearing GetStorage...");
              final storage = GetStorage();

              final savedPasscodeData = storage.read('app_passcode');
              Get.log(
                "💾 [LOGOUT] Saving passcode data before erase: $savedPasscodeData",
              );

              await storage.erase();

              if (savedPasscodeData != null) {
                await storage.write('app_passcode', savedPasscodeData);
                Get.log("✅ [LOGOUT] Passcode restored after erase");
              }
              Get.log("✅ [LOGOUT] GetStorage cleared (passcode preserved)");

              Get.log("🗑️ [LOGOUT] Disposing controllers...");
              _accountController.clearDefaultAccount();
              _accountController.resetAccountsState();
              Get.delete<AccountController>();
              Get.delete<TradingAccountController>();
              Get.delete<TradingController>();
              Get.delete<UserController>();
              Get.delete<HomeController>(force: true);
              Get.log("✅ [LOGOUT] All controllers deleted");

              Get.log("🚀 [LOGOUT] Navigating to MainpageWithoutLogin");
              Get.offAll(() => const MainpageWithoutLogin());
            },
            title: "Keluar",
            textButton: "Ya",
          );
        },
      ),
    );
  }

  String buildFullImageUrl(String? url, [int? version]) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) {
      return version != null ? "$url?v=$version" : url;
    }
    return version != null
        ? "${GlobalVariable.mainURL}$url?v=$version"
        : "${GlobalVariable.mainURL}$url";
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DATA CLASS
// ════════════════════════════════════════════════════════════════════════════
class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;

  _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
    this.trailing,
  });
}
