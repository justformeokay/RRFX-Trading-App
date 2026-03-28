import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/step_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_17.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_3.dart';
import '../controllers/product_controller.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  RxBool selectedCDDType = false.obs;
  RxInt selectedCDDTypeIndex = 1.obs;
  StepController stepController = Get.put(StepController());
  RegolRepository regolRepository = Get.put(RegolRepository());
  StatementController statementController = Get.put(StatementController());
  TextEditingController cddTipeController = TextEditingController();
  TextEditingController typeOfCDDController = TextEditingController();
  final progressController = Get.put(ProgressAccountController());
  final controller = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      typeOfCDDController.text = stepController.typeOfCDDList.first;
      progressController.fetchProgressAccount().then((result){
        final data = progressController.progressData.value;
        final cddList = data?.data?.cddTipe ?? [];
        if (cddList.isEmpty) {
          return CustomScaffoldMessanger.showAppSnackBar(context, message: "CDD Type tidak dapat ditemukan", type: SnackBarType.info);
        }
        selectedCDDType(true);
        cddTipeController.text = stepController.cDDTypesList.first;
      });
    });
  }

  @override
  void dispose() {
    cddTipeController.dispose();
    super.dispose();
  }

  // Widget untuk Form Dropdown di sisi Kiri (atau atas di portrait)
  Widget _buildDropdowns(BuildContext context, Size size, bool isLandscape, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isLandscape ? MainAxisSize.max : MainAxisSize.min, // Biar menyesuaikan di landscape
      children: [
        Obx(() {
          final data = progressController.progressData.value;
          if (progressController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
          }
          final cddList = data?.data?.cddTipe ?? [];
          if (cddList.isEmpty) {
            return const Text("CDD Type belum tersedia");
          }
          return VoidTextField(
            readOnly: false,
            requiredField: true,
            controller: cddTipeController,
            fieldName: "CDD Type",
            hintText: "Pilih CDD Type",
            labelText: "CDD Type",
            onPressed: () {
              CustomMaterialBottomSheets.defaultBottomSheet(
                context,
                size: size,
                title: "Pilih Tipe CDD",
                isScrolledController: false,
                children: List.generate(cddList.length, (index) {
                  final item = cddList[index];
                  if (item.isEmpty) return const SizedBox.shrink();
                  final value = item.values.first;
                  return ListTile(
                    leading: Icon(Icons.check_circle, color: (cddTipeController.text == value) ? CustomColor.secondaryColor : Colors.grey, size: 22),
                    title: Text(value.isNotEmpty ? value : "Tidak diketahui"),
                    onTap: () {
                      setState(() {
                        cddTipeController.text = value;
                        stepController.selectedCDD.value = value;
                        Get.back();
                      });
                      Get.log("Selected CDD Type: ${stepController.selectedCDD.value}");
                    },
                  );
                }),
              );
            },
          );
        }),
        const SizedBox(height: 10),
        Obx(() {
          final data = progressController.progressData.value;
          if (progressController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
          }
          final cddList = data?.data?.cddTipe ?? [];
          if (cddList.isEmpty) {
            return const Text("Type of CDD belum tersedia");
          }
          return VoidTextField(
            readOnly: false,
            requiredField: true,
            controller: typeOfCDDController,
            fieldName: "Type of CDD",
            hintText: "Pilih Type of CDD",
            labelText: "Type of CDD",
            onPressed: () {
              CustomMaterialBottomSheets.defaultBottomSheet(
                context,
                size: size,
                title: "Pilih Type of CDD",
                isScrolledController: false,
                children: List.generate(stepController.typeOfCDDList.length, (index) {
                  final item = stepController.typeOfCDDList[index];
                  if (item.isEmpty) return const SizedBox.shrink();
                  final value = item;
                  return ListTile(
                    leading: Icon(Icons.check_circle, color: (typeOfCDDController.text == value) ? CustomColor.secondaryColor : Colors.grey, size: 22),
                    title: Text(value.isNotEmpty ? value : "Tidak diketahui"),
                    onTap: () {
                      setState(() {
                        typeOfCDDController.text = value;
                        stepController.selectedTypeOfCDD.value = value;
                        Get.back();
                      });
                      Get.log("Selected Type of CDD: ${stepController.selectedTypeOfCDD.value}");
                    },
                  );
                }),
              );
            },
          );
        }),
        // Dropdown Rate
        const Text("Rate"),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white54 : Colors.black54, width: 0.3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedRate.value.isEmpty ? null : controller.selectedRate.value,
              hint: const Text("Pilih Rate"),
              isExpanded: true,
              items: controller.availableRates.map((rate) => DropdownMenuItem(value: rate, child: Text(rate))).toList(),
              onChanged: (value) {
                controller.selectedRate.value = value ?? '';
                controller.selectedProduct.value = null;
              },
            ),
          ),
        ),
        // Tambahkan spacer jika landscape untuk mengisi ruang
        if (isLandscape) const Spacer(),
      ],
    );
  }

  // Widget untuk Daftar Produk dan Tombol di sisi Kanan (atau bawah di portrait)
  Widget _buildProductListAndButton(BuildContext context, bool isDark) {
    final grouped = controller.filteredGroupedProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daftar Produk
        Expanded(
          child: grouped.isEmpty
            ? const Center(child: Text("Tidak ada produk untuk rate ini"))
            : ListView(
                children: grouped.entries.map((entry) {
                  final type = entry.key;
                  final products = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          type.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: CustomColor.secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ...products.map((product) {
                        final isSelected = controller.selectedProduct.value == product;
                        return Obx(() => controller.isLoading.value ? const SizedBox() : GestureDetector(
                              onTap: () {
                                controller.selectedProduct.value = product;
                                controller.komisiSelected.value = product.komisi;
                                print("Selected Komisi: ${controller.komisiSelected.value}");
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            CustomColor.secondaryColor.withOpacity(0.12),
                                            CustomColor.secondaryColor.withOpacity(0.05),
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            isDark ? Colors.grey[850]! : Colors.white,
                                            isDark ? Colors.grey[800]! : Colors.grey[50]!,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? CustomColor.secondaryColor.withOpacity(0.6)
                                        : Colors.grey.withOpacity(0.2),
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.name,
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 18,
                                              color: isSelected
                                                  ? CustomColor
                                                      .secondaryColor
                                                  : (isDark
                                                      ? Colors.white
                                                      : Colors.black87),
                                            ),
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: CustomColor.secondaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Iconsax.verify_bold,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _infoRow("Rate", product.rate, Iconsax.dollar_circle_outline),
                                    _infoRow("Currency", product.currency, Iconsax.global_outline),
                                    _infoRow("Komisi", product.komisi, Iconsax.money_2_outline),
                                    _infoRow("Leverage", "1:${product.leverage}", Iconsax.arrow_up_3_outline),
                                    _infoRow("Free Swap", product.freeswap, Iconsax.flash_1_outline),
                                    _infoRow("Spread", product.spread, Iconsax.activity_outline),
                                    _infoRow("Min Deposit", product.minimumDeposit, Iconsax.wallet_add_outline),
                                    _infoRow("Min Trade", product.minimumTrade, Iconsax.box_tick_outline),
                                  ],
                                ),
                              ),
                            ));
                      }),
                    ],
                  );
                }).toList(),
              ),
        ),
        // Tombol Submit
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0, top: 5.0),
          child: Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.secondaryColor,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: regolRepository.isLoading.value ? null : () async {
                final selectedCDD = (cddTipeController.text == "Standart") ? "1" : "2";
                final alreadyHave = progressController.progressData.value?.data?.alreadyHaveAccount;
                Get.log("Selected Product: ${controller.selectedProduct.value?.name}");
                Get.log("Selected CDD Type: ${stepController.selectedCDD.value}");
                Get.log("Selected Type of CDD: ${stepController.selectedTypeOfCDD.value}");
                Get.log("==================================");
                Get.log("Selected Suffix: ${controller.selectedProduct.value?.suffix}");
                Get.log("Selected CDD: $selectedCDD");
                Get.log("Already Have Account: $alreadyHave");
                Get.log("Skip Regol: ${alreadyHave == null || alreadyHave == false ? 0 : 1}");
                final selected = controller.selectedProduct.value;
                if (selected == null) {
                  AppSnackbar.error("Silakan pilih produk terlebih dahulu!");
                  return;
                }
                Future<void> handleStep({
                  required int skipRegol,
                  required Widget nextStep,
                }) async {
                  final success = await regolRepository.step2(
                    accountType: selected.suffix,
                    cddType: selectedCDD,
                    skipRegol: skipRegol,
                  );

                  if (!success) {
                    return AppSnackbar.error("Gagal submit produk. ${regolRepository.responseMessage.value}");
                  }
                  Get.to(() => nextStep);
                }
                
                if (alreadyHave == null || alreadyHave == false) {
                  await handleStep(skipRegol: 0, nextStep: const Step3());
                } else {
                  await _showChangeDataDialog(
                    context,
                    regolRepository: regolRepository,
                    selectedSuffix: selected.suffix,
                    selectedCDD: selectedCDD,
                    onChangeData: () => handleStep(skipRegol: 0, nextStep: const Step3()),
                    onContinue: () => handleStep(skipRegol: 1, nextStep: const Step17()),
                  );
                }
              },
              child: Text(
                regolRepository.isLoading.value ? "Memproses..." : "Submit Produk",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    // Cek orientasi
    final isLandscape = size.width > size.height;

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Pilih Produk",
        autoImplyLeading: true
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: isLandscape
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2, // Menggunakan flex 2
                    child: _buildDropdowns(context, size, isLandscape, isDark),
                  ),
                  const VerticalDivider(width: 24, thickness: 1), // Pemisah visual
                  Flexible(
                    flex: 3, // Menggunakan flex 3 (lebih besar)
                    child: _buildProductListAndButton(context, isDark),
                  ),
                ],
              )
            : Column( // Tampilan default (Portrait)
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdowns(context, size, isLandscape, isDark),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildProductListAndButton(context, isDark),
                  ),
                ],
              ),
        );
      }),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Row(
            children: [
              Icon(icon, size: 22, color: CustomColor.secondaryColor),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _showChangeDataDialog(
    BuildContext context, {
    required RegolRepository regolRepository,
    required String selectedSuffix,
    required String selectedCDD,
    required VoidCallback onChangeData,
    required VoidCallback onContinue,
  }) async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline,
                  color: CustomColor.secondaryColor, size: 50),
              const SizedBox(height: 16),
              Text(
                "Apakah Anda perlu melakukan perubahan data sebelum melanjutkan?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onChangeData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: CustomColor.secondaryColor,
                        side: BorderSide(color: CustomColor.secondaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Perlu Ubah Data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        "Langsung Lanjut",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}