import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';

class AgreementDisputeSection extends StatefulWidget {
  /// Callback yang akan dipanggil setiap kali pilihan berubah
  final void Function(Map<String, String>)? onChanged;

  const AgreementDisputeSection({super.key, this.onChanged});

  @override
  State<AgreementDisputeSection> createState() => _AgreementDisputeSectionState();
}

class _AgreementDisputeSectionState extends State<AgreementDisputeSection> {
  final progressController = Get.put(ProgressAccountController());

  String? selectedPenyelesaian;
  String? selectedKota;
  bool agreed = false;

  @override
  void initState() {
    super.initState();
    // Ambil data dari API
    Future.microtask(() async {
      await progressController.fetchProgressAccount();
    });
  }

  void _notifyParent() {
    if (widget.onChanged != null) {
      widget.onChanged!({
        "penyelesaian_perselisihan": selectedPenyelesaian ?? "",
        "daftar_kantor": selectedKota ?? "",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = CustomColor.secondaryColor;

    return Obx(() {
      final data = progressController.progressData.value?.data;
      final isLoading = progressController.isLoading.value;

      final listKantor = data?.listKantorPenyelesaian ?? {};
      final listKota = data?.listKotaPenyelesaian ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "23. ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Expanded(
                child: Text(
                  "Penyelesaian Perselisihan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildNumberedText(
            "(1)",
            "Semua perselisihan dan perbedaan pendapat yang timbul dalam pelaksanaan Perjanjian ini wajib diselesaikan terlebih dahulu secara musyawarah untuk mencapai mufakat antara Para Pihak.",
          ),
          _buildNumberedText(
            "(2)",
            "Apabila perselisihan dan perbedaan pendapat yang timbul tidak dapat diselesaikan secara musyawarah untuk mencapai mufakat, Para Pihak wajib memanfaatkan sarana penyelesaian perselisihan yang tersedia di Bursa Berjangka.",
          ),
          _buildNumberedText(
            "(3)",
            "Apabila perselisihan dan perbedaan pendapat yang timbul tidak dapat diselesaikan melalui cara sebagaimana dimaksud pada angka (1) dan angka (2), maka Para Pihak sepakat untuk menyelesaikan perselisihan melalui *):",
          ),

          // 🔹 Radio daftar penyelesaian (dari API)
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                children: listKantor.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;
                  return RadioListTile<String>(
                    value: key,
                    groupValue: selectedPenyelesaian,
                    activeColor: primary,
                    onChanged: (val) {
                      setState(() => selectedPenyelesaian = val);
                      _notifyParent();
                    },
                    title: Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
                  );
                }).toList(),
              ),
            ),

          _buildNumberedText(
            "(4)",
            "Kantor atau kantor cabang Pialang Berjangka terdekat dengan domisili Nasabah tempat penyelesaian dalam hal terjadi perselisihan. Kantor yang dipilih (salah satu) *):",
          ),
          const Padding(
            padding: EdgeInsets.only(left: 32, top: 4, bottom: 4),
            child: Text(
              "Daftar Kantor:",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          // 🔹 Radio daftar kota (dari API)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              children: listKota.map((kota) {
                return RadioListTile<String>(
                  value: kota,
                  groupValue: selectedKota,
                  activeColor: primary,
                  onChanged: (val) {
                    setState(() => selectedKota = val);
                    _notifyParent();
                  },
                  title: Text(kota, style: const TextStyle(fontSize: 15, height: 1.4)),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 Checkbox persetujuan
          Row(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  checkboxTheme: CheckboxThemeData(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(width: 1.5, color: Colors.grey),
                    fillColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) => states.contains(WidgetState.selected) ? primary : null,
                    ),
                    checkColor: WidgetStateProperty.all(Colors.white),
                  ),
                ),
                child: Checkbox(
                  value: agreed,
                  onChanged: (val) {
                    setState(() => agreed = val ?? false);
                    _notifyParent();
                  },
                ),
              ),
              const Expanded(
                child: Text(
                  "Saya sudah membaca dan memahami *)",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildNumberedText(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$number ", style: const TextStyle(fontSize: 15, height: 1.4)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
