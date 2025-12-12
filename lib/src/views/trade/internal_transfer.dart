import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/loadings/default.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/controllers/trading.dart';

class InternalTransfer extends StatefulWidget {
  const InternalTransfer({super.key, this.loginID, this.loginNumber});
  final String? loginNumber;
  final String? loginID;

  @override
  State<InternalTransfer> createState() => _InternalTransferState();
}

class _InternalTransferState extends State<InternalTransfer> {
  RxBool isLoading = false.obs;
  final _formKey = GlobalKey<FormState>();
  RxString selectedSenderLogin = "".obs;
  RxString selectedReceiverLogin = "".obs;
  RxString amountText = "".obs; // Reactive variable untuk track amount changes

  SettingController settingController = Get.put(SettingController());
  TradingController tradingController = Get.put(TradingController());
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLoading(true);

    // Add listener to track amount changes
    amountController.addListener(() {
      amountText(amountController.text);
    });

    Future.delayed(Duration.zero, () {
      tradingController.getTradingAccount().then((result) {
        if (widget.loginID != null) {
          selectedSenderLogin(widget.loginID!);
        }
        if (!result) {
          if (mounted) {
            CustomAlert.alertError(
              context,
              message: tradingController.responseMessage.value,
            );
          }
        }
        isLoading(false);
      });
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  String _formatMoney(String? value) {
    if (value == null || value.isEmpty) return "0.00";
    final num = double.tryParse(value) ?? 0;
    return num.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Transfer Internal",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Title Section
                  Text(
                    "Transfer Dana Antar Akun",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Transfer instan tanpa biaya tambahan",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Rate Requirement
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Transfer hanya dapat dilakukan antar akun dengan rate yang sama (IDR ke IDR atau USD ke USD)",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color:
                                  isDark
                                      ? Colors.blue.shade200
                                      : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Step 1: From Account
                  Obx(
                    () => _buildAccountSelector(
                      title: "1. Dari Akun",
                      subtitle: "Pilih akun sumber dana",
                      selectedLogin: selectedSenderLogin.value,
                      excludeLogin: null,
                      onSelect: (login) {
                        // Get accounts to check rate compatibility
                        final accounts =
                            tradingController
                                .tradingAccountModels
                                .value
                                ?.response
                                .real ??
                            [];
                        final newSender = accounts.firstWhereOrNull(
                          (acc) => acc.login == login,
                        );
                        final receiver = accounts.firstWhereOrNull(
                          (acc) => acc.login == selectedReceiverLogin.value,
                        );

                        selectedSenderLogin(login);

                        // Reset receiver jika sama atau rate berbeda
                        if (selectedReceiverLogin.value == login) {
                          selectedReceiverLogin("");
                        } else if (receiver != null &&
                            newSender != null &&
                            receiver.rate != newSender.rate) {
                          // Reset receiver jika rate tidak sama dengan sender baru
                          selectedReceiverLogin("");
                          amountController.clear();
                          amountText("");
                        }
                      },
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Transfer Arrow Indicator
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CustomColor.secondaryColor.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: CustomColor.secondaryColor,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Step 2: To Account
                  Obx(() {
                    // Get sender account to get rate
                    final sender = tradingController
                        .tradingAccountModels
                        .value
                        ?.response
                        .real
                        ?.firstWhereOrNull(
                          (acc) => acc.login == selectedSenderLogin.value,
                        );
                    final senderRate = sender?.rate;

                    return _buildAccountSelector(
                      title: "2. Ke Akun",
                      subtitle: "Pilih akun tujuan",
                      selectedLogin: selectedReceiverLogin.value,
                      excludeLogin: selectedSenderLogin.value,
                      senderRate: senderRate, // Pass sender rate untuk filter
                      onSelect: (login) {
                        selectedReceiverLogin(login);
                      },
                      isDark: isDark,
                    );
                  }),

                  const SizedBox(height: 32),

                  // Step 3: Amount
                  Obx(() => _buildAmountSection(isDark)),

                  const SizedBox(height: 32),

                  // Transfer Summary (if both accounts selected)
                  Obx(() {
                    if (selectedSenderLogin.value.isEmpty ||
                        selectedReceiverLogin.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _buildTransferSummary(isDark);
                  }),

                  const SizedBox(height: 24),

                  // Submit Button
                  Obx(() => _buildSubmitButton(isDark)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
            Obx(
              () =>
                  LoadingOverlay(isLoading: settingController.isLoading.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector({
    required String title,
    required String subtitle,
    required String selectedLogin,
    required String? excludeLogin,
    required Function(String login) onSelect,
    required bool isDark,
    String? senderRate, // Parameter baru untuk filter by rate
  }) {
    final accounts =
        tradingController.tradingAccountModels.value?.response.real ?? [];

    // Filter akun berdasarkan excludeLogin dan senderRate
    List<dynamic> filteredAccounts = accounts;

    if (excludeLogin != null) {
      filteredAccounts =
          filteredAccounts.where((acc) => acc.login != excludeLogin).toList();
    }

    // Jika senderRate tidak null, filter hanya akun dengan rate yang sama
    if (senderRate != null && senderRate.isNotEmpty) {
      filteredAccounts =
          filteredAccounts.where((acc) => acc.rate == senderRate).toList();
    }

    final selectedAccount = accounts.firstWhereOrNull(
      (acc) => acc.login == selectedLogin,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomColor.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: CustomColor.secondaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap:
              () => _showAccountPicker(
                context: context,
                accounts: filteredAccounts,
                selectedLogin: selectedLogin,
                onSelect: onSelect,
                isDark: isDark,
                senderRate: senderRate, // Pass senderRate ke picker
              ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    selectedAccount != null
                        ? CustomColor.secondaryColor
                        : Colors.grey.shade300,
                width: selectedAccount != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                selectedAccount != null
                    ? Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomColor.secondaryColor.withValues(
                                  alpha: 0.8,
                                ),
                                CustomColor.secondaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_circle_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Akun #${selectedAccount.login}",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Rate badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (selectedAccount.rate == "IDR"
                                              ? Colors.green
                                              : Colors.blue)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: (selectedAccount.rate == "IDR"
                                                ? Colors.green
                                                : Colors.blue)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      selectedAccount.rate ?? "USD",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            selectedAccount.rate == "IDR"
                                                ? Colors.green.shade700
                                                : Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Balance: \$${_formatMoney(selectedAccount.balance)}",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: CustomColor.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.grey.shade600,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Pilih akun",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomColor.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.payments_rounded,
                color: CustomColor.secondaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "3. Jumlah Transfer",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  "Masukkan nominal yang akan ditransfer",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "USD",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                enabled: _isAmountFieldEnabled(),
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color:
                      _isAmountFieldEnabled()
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey.shade400,
                ),
                decoration: InputDecoration(
                  hintText: "0.00",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 12),
                    child: Text(
                      "\$",
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                onChanged: (value) {
                  // Format on change - hanya angka dan titik
                  if (value.isNotEmpty) {
                    final cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
                    if (cleanValue != value) {
                      amountController.value = TextEditingValue(
                        text: cleanValue,
                        selection: TextSelection.collapsed(
                          offset: cleanValue.length,
                        ),
                      );
                    }
                  }
                  // Update reactive variable untuk trigger Obx rebuild
                  amountText(value);
                },
              ),
            ],
          ),
        ),

        // Warning message when balance is 0
        if (!_isAmountFieldEnabled() && selectedSenderLogin.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Saldo akun pengirim tidak mencukupi (\$0.00)",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransferSummary(bool isDark) {
    final sender = tradingController.tradingAccountModels.value?.response.real
        ?.firstWhereOrNull((acc) => acc.login == selectedSenderLogin.value);
    final receiver = tradingController.tradingAccountModels.value?.response.real
        ?.firstWhereOrNull((acc) => acc.login == selectedReceiverLogin.value);

    if (sender == null || receiver == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColor.secondaryColor.withValues(alpha: 0.1),
            CustomColor.secondaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomColor.secondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: CustomColor.secondaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Ringkasan Transfer",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow("Dari", "Akun #${sender.login}", isDark),
          const SizedBox(height: 8),
          _buildSummaryRow("Ke", "Akun #${receiver.login}", isDark),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Transfer",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Obx(
                () => Text(
                  "\$${amountText.value.isEmpty ? '0.00' : _formatMoney(amountText.value)}",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomColor.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final receiverBalance =
                double.tryParse(receiver.balance ?? "0") ?? 0;
            final transferAmount =
                double.tryParse(
                  amountText.value.isEmpty ? "0" : amountText.value,
                ) ??
                0;
            final finalBalance = receiverBalance + transferAmount;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CustomColor.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Balance Penerima",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Setelah Transfer",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "\$${_formatMoney(finalBalance.toString())}",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomColor.secondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    // Get sender account balance
    final sender = tradingController.tradingAccountModels.value?.response.real
        ?.firstWhereOrNull((acc) => acc.login == selectedSenderLogin.value);
    final senderBalance = double.tryParse(sender?.balance ?? "0") ?? 0;

    final isEnabled =
        selectedSenderLogin.value.isNotEmpty &&
        selectedReceiverLogin.value.isNotEmpty &&
        amountText.value.isNotEmpty &&
        senderBalance > 0 &&
        !settingController.isLoading.value;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleTransfer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColor.secondaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: isEnabled ? 4 : 0,
          shadowColor: CustomColor.secondaryColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            settingController.isLoading.value
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      "Konfirmasi Transfer",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  void _showAccountPicker({
    required BuildContext context,
    required List accounts,
    required String selectedLogin,
    required Function(String login) onSelect,
    required bool isDark,
    String? senderRate, // Tambah parameter untuk info rate
  }) {
    if (accounts.isEmpty) {
      // Pesan yang lebih informatif
      final message =
          senderRate != null && senderRate.isNotEmpty
              ? "Tidak ada akun tersedia dengan rate $senderRate"
              : "Tidak ada akun tersedia";

      CustomScaffoldMessanger.showAppSnackBar(context, message: message);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Pilih Akun",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info box jika filter berdasarkan rate
                if (senderRate != null && senderRate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Menampilkan hanya akun dengan rate $senderRate",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? Colors.blue.shade200
                                      : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ...accounts.map((acc) {
                  final isSelected = acc.login == selectedLogin;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        onSelect(acc.login ?? "");
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? CustomColor.secondaryColor.withValues(
                                    alpha: 0.1,
                                  )
                                  : (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? CustomColor.secondaryColor
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected
                                        ? LinearGradient(
                                          colors: [
                                            CustomColor.secondaryColor
                                                .withValues(alpha: 0.8),
                                            CustomColor.secondaryColor,
                                          ],
                                        )
                                        : null,
                                color: isSelected ? null : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Akun #${acc.login}",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Rate badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (acc.rate == "IDR"
                                                  ? Colors.green
                                                  : Colors.blue)
                                              .withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: (acc.rate == "IDR"
                                                    ? Colors.green
                                                    : Colors.blue)
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          acc.rate ?? "USD",
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                acc.rate == "IDR"
                                                    ? Colors.green.shade700
                                                    : Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "\$${_formatMoney(acc.balance)}",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: CustomColor.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: CustomColor.secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  bool _isAmountFieldEnabled() {
    if (selectedSenderLogin.value.isEmpty) return false;

    final sender = tradingController.tradingAccountModels.value?.response.real
        ?.firstWhereOrNull((acc) => acc.login == selectedSenderLogin.value);
    final senderBalance = double.tryParse(sender?.balance ?? "0") ?? 0;

    return senderBalance > 0;
  }

  void _handleTransfer() async {
    if (selectedSenderLogin.value.isEmpty) {
      CustomScaffoldMessanger.showAppSnackBar(
        context,
        message: "Pilih akun pengirim terlebih dahulu",
      );
      return;
    }

    if (selectedReceiverLogin.value.isEmpty) {
      CustomScaffoldMessanger.showAppSnackBar(
        context,
        message: "Pilih akun penerima terlebih dahulu",
      );
      return;
    }

    if (selectedSenderLogin.value == selectedReceiverLogin.value) {
      CustomScaffoldMessanger.showAppSnackBar(
        context,
        message: "Akun pengirim dan penerima tidak boleh sama",
      );
      return;
    }

    if (amountController.text.isEmpty) {
      CustomScaffoldMessanger.showAppSnackBar(
        context,
        message: "Masukkan jumlah transfer",
      );
      return;
    }

    // final amount = NumberFormatter.cleanCurrencyString(amountController.text);
    final result = await settingController.internalTransfer(
      // amount: amount,
      amount: amountController.text,
      tradingIDReceiver: selectedReceiverLogin.value,
      tradingIDSender: selectedSenderLogin.value,
    );

    if (result) {
      if (mounted) {
        CustomAlert.alertDialogCustomSuccess(
          context,
          message: settingController.responseMessage.value,
          onTap: () {
            Get.back();
            Get.back();
          },
        );
      }
    } else {
      if (mounted) {
        CustomAlert.alertError(
          context,
          message: settingController.responseMessage.value,
        );
      }
    }
  }
}
