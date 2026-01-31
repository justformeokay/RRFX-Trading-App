import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_7.dart';

class SIDRegistrationPage extends StatefulWidget {
  const SIDRegistrationPage({super.key});

  @override
  State<SIDRegistrationPage> createState() => _SIDRegistrationPageState();
}

class _SIDRegistrationPageState extends State<SIDRegistrationPage> {
  // States
  int? selectedOption; // null = belum pilih, 0 = punya SID, 1 = tidak punya SID

  // Single SID Input Controller
  late TextEditingController _sidController;
  final RegolRepository _regolRepository = Get.put(RegolRepository());
  final progressController = Get.find<ProgressAccountController>();

  // Separated SID Input Controllers
  late TextEditingController _typeController;
  late TextEditingController _statusController;
  late TextEditingController _dateController;
  late TextEditingController _tradingIdController;
  late TextEditingController _checkDigitController;

  @override
  void initState() {
    super.initState();
    _sidController = TextEditingController();
    _sidController.addListener(() => setState(() {}));

    // Initialize separated controllers
    _typeController = TextEditingController();
    _statusController = TextEditingController();
    _dateController = TextEditingController();
    _tradingIdController = TextEditingController();
    _checkDigitController = TextEditingController();

    // Add listeners for real-time preview
    _typeController.addListener(() => setState(() {}));
    _statusController.addListener(() => setState(() {}));
    _dateController.addListener(() => setState(() {}));
    _tradingIdController.addListener(() => setState(() {}));
    _checkDigitController.addListener(() => setState(() {}));

    // Auto-fill SID if available
    _autoFillSID();
  }

  void _autoFillSID() {
    final nomorSID = progressController.progressData.value?.response?.nomorSID;
    if (nomorSID != null && nomorSID.isNotEmpty) {
      print('SID Available: $nomorSID');
      
      // Parse SID format: "ID - D - 1199 - AB1234 - 56" or "IDD119934219456"
      try {
        // Remove all dashes and spaces
        String cleanSID = nomorSID.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
        
        if (cleanSID.length >= 15) {
          // Extract each part
          final type = cleanSID.substring(0, 2); // 2 chars
          final status = cleanSID.substring(2, 3); // 1 char
          final dateOfBirth = cleanSID.substring(3, 7); // 4 chars
          final tradingId = cleanSID.substring(7, 13); // 6 chars
          final checkDigit = cleanSID.substring(13, 15); // 2 chars
          
          // Fill the controllers
          _typeController.text = type;
          _statusController.text = status;
          _dateController.text = dateOfBirth;
          _tradingIdController.text = tradingId;
          _checkDigitController.text = checkDigit;
          
          // Set option to "has SID"
          setState(() {
            selectedOption = 0;
          });
          
          print('Auto-filled SID: $type-$status-$dateOfBirth-$tradingId-$checkDigit');
        } else {
          print('SID length is less than 15 characters. Got: ${cleanSID.length} characters');
        }
      } catch (e) {
        print('Error parsing SID: $e');
      }
    } else {
      print('SID not available or empty');
    }
  }

  @override
  void dispose() {
    _sidController.dispose();
    _typeController.dispose();
    _statusController.dispose();
    _dateController.dispose();
    _tradingIdController.dispose();
    _checkDigitController.dispose();
    super.dispose();
  }

  String _getFormattedSID() {
    return '${_typeController.text} - ${_statusController.text} - ${_dateController.text} - ${_tradingIdController.text} - ${_checkDigitController.text}'
        .toUpperCase();
  }

  String _previewSID() {
    return '${_typeController.text}-${_statusController.text}-${_dateController.text}-${_tradingIdController.text}-${_checkDigitController.text}'
        .toUpperCase();
  }

  String _getFullSID() {
    return '${_typeController.text}${_statusController.text}${_dateController.text}${_tradingIdController.text}${_checkDigitController.text}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Iconsax.arrow_left_2_bold,
                color: Theme.of(context).iconTheme.color),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Nomor SID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: selectedOption == null
            ? _buildOptionSelectionView()
            : selectedOption == 0
                ? _buildHasSIDView()
                : _buildNoSIDView(),
        bottomNavigationBar: selectedOption != null ? _buildBottomButton() : null,
      ),
    );
  }

  // View: Option Selection
  Widget _buildOptionSelectionView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Option 1: No SID
            _buildOptionCard(
              title: 'Tidak, saya belum memiliki SID',
              icon: Iconsax.close_circle_bold,
              iconColor: Colors.grey,
              description:
                  'Dengan ini Nasabah menyetujui PT. RRFX Investasi Berjangka akan melakukan pembuatan Single Investor Identification (SID) sesuai dengan ketentuan KSEI dan/atau Otoritas Jasa Keuangan (OJK) yang berlaku.\n\nNasabah mengerti dan menyetujui bahwa PT. RRFX Investasi Berjangka menyampaikan kepada KSEI data dan/atau dokumen pribadi namun tidak terbatas pada informasi yang telah Nasabah sampaikan kepada PT. RRFX Investasi Berjangka dalam Aplikasi Pembukaan Rekening Transaksi untuk proses pembuatan Single Investor Identification (SID) dan/atau pengkinian data.',
              onTap: () {
                setState(() {
                  selectedOption = 1;
                });
              },
            ),
            const SizedBox(height: 20),
            // Option 2: Has SID
            _buildOptionCard(
              title: 'Ya, saya sudah memiliki SID',
              icon: Iconsax.tick_circle_bold,
              iconColor: Colors.orange,
              description:
                  'Dengan ini Nasabah menyetujui PT. RRFX Investasi Berjangka dapat mengakses data Nasabah menggunakan Single Investor Identification (SID) dan/atau melakukan pengkinian data melalui sistem yang disediakan oleh KSEI apabila terdapat perubahan data Nasabah sebagai bagian dari penerepan Prinsip Mengenali Nasabah sesuai dengan ketentuan KSEI dan/atau Otoritas Jasa Keuangan (OJK) yang berlaku.',
              onTap: () {
                setState(() {
                  selectedOption = 0;
                });
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // View: Has SID
  Widget _buildHasSIDView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomColor.secondaryColor.withOpacity(0.1),
                    CustomColor.secondaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomColor.secondaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Iconsax.tick_circle_bold,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ya, saya sudah memiliki SID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Input Section
            const Text(
              'Masukkan Nomor SID Anda',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomColor.secondaryColor.withOpacity(0.1),
                    CustomColor.secondaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomColor.secondaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arti Digit Nomor SID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSIDDigitExplanation(
                    digit: '1',
                    title: 'Tipe Investor',
                    description: 'ID untuk persorangan, SC untuk perusahaan, MF untuk Mutual Fund',
                  ),
                  _buildSIDDigitExplanation(
                    digit: '2',
                    title: 'Status Investor',
                    description: 'D untuk investor domestik, F untuk investor asing',
                  ),
                  _buildSIDDigitExplanation(
                    digit: '3',
                    title: 'Bulan & Tanggal Lahir',
                    description: 'Format MMDD untuk verifikasi data kependudukan milik Dukcapil',
                  ),
                  _buildSIDDigitExplanation(
                    digit: '4',
                    title: 'Trading ID',
                    description: 'Digit yang wajib digunakan setiap pelaksanaan transaksi di pasar modal',
                  ),
                  _buildSIDDigitExplanation(
                    digit: '5',
                    title: 'Check Digit',
                    description: 'Angka yang dihasilkan sistem secara random untuk memastikan keaslian SID',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Formatted Input Fields
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildSIDInputField(
                    label: 'Tipe',
                    hint: 'ID',
                    controller: _typeController,
                    maxLength: 2,
                    inputType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildSIDInputField(
                    label: 'Status',
                    hint: 'D',
                    controller: _statusController,
                    maxLength: 1,
                    inputType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildSIDInputField(
                    label: 'Tgl Lahir',
                    hint: 'MMDD',
                    controller: _dateController,
                    maxLength: 4,
                    inputType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSIDInputField(
                    label: 'Trading ID',
                    hint: 'AB1234',
                    controller: _tradingIdController,
                    maxLength: 6,
                    inputType: TextInputType.text,
                    isAlphanumericOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildSIDInputField(
                    label: 'Check',
                    hint: '56',
                    controller: _checkDigitController,
                    maxLength: 2,
                    inputType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Preview Section
            if (_getFullSID().length > 8)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: CustomColor.secondaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.eye_bold,
                          color: CustomColor.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Preview SID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: CustomColor.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                CustomColor.secondaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _previewSID(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),
            // Preview Section
            if (_sidController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: CustomColor.secondaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.eye_bold,
                          color: CustomColor.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Preview SID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: CustomColor.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                CustomColor.secondaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _sidController.text.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.info_circle_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Informasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dengan ini Nasabah menyetujui PT. RRFX Investasi Berjangka dapat mengakses data Nasabah menggunakan Single Investor Identification (SID) dan/atau melakukan pengkinian data melalui sistem yang disediakan oleh KSEI apabila terdapat perubahan data Nasabah sebagai bagian dari penerepan Prinsip Mengenali Nasabah sesuai dengan ketentuan KSEI dan/atau Otoritas Jasa Keuangan (OJK) yang berlaku.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // View: No SID
  Widget _buildNoSIDView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.1),
                    Colors.grey.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Iconsax.close_circle_bold,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tidak, saya belum memiliki SID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Proses Pembuatan SID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoStep(
                    number: '1',
                    title: 'Dengan ini Nasabah menyetujui',
                    description:
                        'PT. RRFX Investasi Berjangka akan melakukan pembuatan Single Investor Identification (SID) sesuai dengan ketentuan KSEI dan/atau Otoritas Jasa Keuangan (OJK) yang berlaku.',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoStep(
                    number: '2',
                    title: 'Nasabah mengerti dan menyetujui bahwa',
                    description:
                        'PT. RRFX Investasi Berjangka menyampaikan kepada KSEI data dan/atau dokumen pribadi namun tidak terbatas pada informasi yang telah Nasabah sampaikan kepada PT. RRFX Investasi Berjangka dalam Aplikasi Pembukaan Rekening Transaksi untuk proses pembuatan Single Investor Identification (SID) dan/atau pengkinian data.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final isValidSID = selectedOption == 0
        ? _typeController.text.isNotEmpty &&
            _statusController.text.isNotEmpty &&
            _dateController.text.isNotEmpty &&
            _tradingIdController.text.isNotEmpty &&
            _checkDigitController.text.isNotEmpty
        : true;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            if (selectedOption != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedOption = null;
                      _sidController.clear();
                      _typeController.clear();
                      _statusController.clear();
                      _dateController.clear();
                      _tradingIdController.clear();
                      _checkDigitController.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: CustomColor.secondaryColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CustomColor.secondaryColor,
                    ),
                  ),
                ),
              ),
            if (selectedOption != null) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isValidSID
                    ? () async {
                        final sidData = {
                          'hasSID': selectedOption == 0,
                          if (selectedOption == 0) ...{
                            'sid': _getFullSID(),
                            'sidFormatted': _getFormattedSID(),
                            'type': _typeController.text,
                            'status': _statusController.text,
                            'dateOfBirth': _dateController.text,
                            'tradingId': _tradingIdController.text,
                            'checkDigit': _checkDigitController.text,
                          }
                        };

                        print('SID Data: $sidData');
                        if (selectedOption == 0) {
                          print('Formatted SID: ${_getFormattedSID()}');
                        }

                        // Show loading dialog
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            content: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      CustomColor.secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Memproses data...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          barrierDismissible: false,
                        );

                        // Determine keterangan based on SID status
                        final String keterangan = selectedOption == 0 ? "1" : "2";
                        final String? sidValue = selectedOption == 0 ? _getFormattedSID() : null;

                        // DEBUG: Log data sebelum dikirim
                        Get.log('========== DEBUG SEBELUM SUBMIT SID ==========');
                        Get.log('Selected Option: $selectedOption (0=punya SID, 1=tidak punya)');
                        Get.log('Keterangan: $keterangan');
                        Get.log('SID Value: $sidValue');
                        Get.log('Full SID (no formatting): ${_getFullSID()}');
                        Get.log('Type: ${_typeController.text}');
                        Get.log('Status: ${_statusController.text}');
                        Get.log('Date: ${_dateController.text}');
                        Get.log('Trading ID: ${_tradingIdController.text}');
                        Get.log('Check Digit: ${_checkDigitController.text}');
                        Get.log('==========================================');

                        // Call API
                        bool result = await _regolRepository.step6ASID(
                          sid: sidValue,
                          keterangan: keterangan,
                        );

                        // Dismiss loading dialog
                        Get.back();

                        // Show success or failure popup
                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Data berhasil disimpan'),
                              backgroundColor: CustomColor.secondaryColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          // Navigate to next page
                          Future.delayed(const Duration(seconds: 2), () {
                            Get.to(() => const Step7());
                          });
                        } else {
                          _showSIDErrorPopup(context);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lanjutkan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isValidSID ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSIDDigitExplanation({
    required String digit,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: CustomColor.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                digit,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSIDInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required int maxLength,
    required TextInputType inputType,
    bool isAlphanumericOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: inputType,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            if (inputType == TextInputType.number)
              FilteringTextInputFormatter.digitsOnly
            else if (isAlphanumericOnly)
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
            else
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(maxLength),
          ],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          decoration: InputDecoration(
            hintText: hint.toUpperCase(),
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE5E5E5),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: CustomColor.secondaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  void _showSIDErrorPopup(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.close_circle_bold,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Data Tidak Valid',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Gagal menyimpan data SID. Silakan periksa kembali informasi yang Anda masukkan atau coba lagi nanti.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Error Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.info_circle_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pastikan format SID benar atau Anda belum memiliki SID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: CustomColor.secondaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          // Reset form
                          setState(() {
                            selectedOption = null;
                            _sidController.clear();
                            _typeController.clear();
                            _statusController.clear();
                            _dateController.clear();
                            _tradingIdController.clear();
                            _checkDigitController.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Ulangi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
