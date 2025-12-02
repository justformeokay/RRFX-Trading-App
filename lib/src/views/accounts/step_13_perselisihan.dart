import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_14_dokumen_persetujuan.dart' show Step14KelengkapanDokumenPerusahaan;
import 'package:rrfx/src/views/mainpage.dart';
import 'components/step_position.dart';

class Step13PenyelesaianPerselisihan extends StatefulWidget {
  const Step13PenyelesaianPerselisihan({super.key});

  @override
  State<Step13PenyelesaianPerselisihan> createState() => _Step13PenyelesaianPerselisihan();
}

class _Step13PenyelesaianPerselisihan extends State<Step13PenyelesaianPerselisihan> {

  final _formKey = GlobalKey<FormState>();
  RegolController regolController = Get.find();
  TextEditingController tempatPenyelesaianPerselisihanController = TextEditingController();
  TextEditingController kantorPialangBerjangka = TextEditingController();
  RxString selectedPerselisihan = "".obs;
  RxString selectedKantorCabang = "".obs;

  List<Map<String, String>> tempatPenyelesaianPerselisihan = [
    {
      "bakti" : "Badan Arbitrase Perdagangan Berjangka Komoditi (BAKTI) berdasarkan Peraturan dan Prosedur Badan Arbitrase Perdagangan Berjangka Komoditi (BAKTI)",
    },
    {
      "pengadilan_negeri_jakarta" : "Pengadilan Negeri Jakarta"
    }
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    kantorPialangBerjangka.dispose();
    tempatPenyelesaianPerselisihanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Peraturan",
          actions: [
            CupertinoButton(
              onPressed: (){
                CustomAlert.alertDialogCustomInfo(
                  title: "Confirmation",
                  message: "Are you sure you want to cancel? All data will be lost.",
                  moreThanOneButton: true,
                  onTap: () {
                    Get.offAll(() => const Mainpage());
                  },
                  textButton: "Yes",
                );
              },
              child: Text(LanguageGlobalVar.CANCEL.tr, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CustomColor.defaultColor)),
            )
          ]
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // UtilitiesWidget.titleContent(
                //   title: "Perjanjian",
                //   subtitle: "Sebelum melakukan Transaksi Perdagangan Berjangka di ${GlobalVariable.namaPerusahaan}, anda harus mengerti, memahami dan menyetujui Dokumen Perjanjian dan Peraturan Transaksi dan dokumen lainnya",
                //   children: [
                //     CheckboxListTile(
                //       contentPadding: EdgeInsets.zero,
                //       title: Text('Dokumen Perjanjian, Peraturan Transaksi dan Pernyataan', style: GoogleFonts.inter(fontSize: 16.0)),
                //       value: true,
                //       onChanged:(bool? value) {},
                //     ),
                //     CheckboxListTile(
                //       contentPadding: EdgeInsets.zero,
                //       title: Text('Tidak Bekerja atau memiliki anggota keluarga yang bekerja di BAPPEBTI/Bursa Berjangka/Kliring Berjangka?', style: GoogleFonts.inter(fontSize: 16.0)),
                //       value: true,
                //       onChanged:(bool? value) {},
                //     ),
                //     CheckboxListTile(
                //       contentPadding: EdgeInsets.zero,
                //       title: Text('Tidak pernah atau dinyatakan pailit oleh pengadilan?', style: GoogleFonts.inter(fontSize: 16.0)),
                //       value: true,
                //       onChanged:(bool? value) {},
                //     ),
                //   ]
                // ),

                UtilitiesWidget.titleContent(
                  title: "Penyelesaian Perselisihan",
                  subtitle: "Apabila perselisihan dan perbedaan pendapat yang timbul dan tidak dapat diselesaikan secara musyawarah untuk mufakat, maka para pihak sepakat untuk menyelesaikan perselisihan melalui",
                  children: [
                    VoidTextField(controller: tempatPenyelesaianPerselisihanController, fieldName: "Tempat Penyelesaian Perselisihan", hintText: "Tempat Penyelesaian Perselisihan", labelText: "Tempat Penyelesaian Perselisihan", onPressed: () async {
                      CustomMaterialBottomSheets.defaultBottomSheet(
                        context,
                        size: size,
                        title: "Pilih tempat penyelesaian perselisihan",
                        children: List.generate(tempatPenyelesaianPerselisihan.length, (i) {
                          // ambil key dan value
                          final key = tempatPenyelesaianPerselisihan[i].keys.first;
                          final value = tempatPenyelesaianPerselisihan[i][key]!;

                          return ListTile(
                            onTap: () {
                              Navigator.pop(context);

                              // kalau kamu mau set text pakai value:
                              tempatPenyelesaianPerselisihanController.text = value;

                              // kalau kamu butuh key untuk function
                              selectedPerselisihan(key);
                            },
                            title: Text(value, style: GoogleFonts.inter()),
                          );
                        }),
                      );
                    }),
                  ]
                ),

                UtilitiesWidget.titleContent(
                    title: "Kantor Cabang Perusahaan Pialang Berjangka",
                    subtitle: "Kantor atau Kantor cabang Pialang Berjangka terdekat dengan domisili Nasabah tempat penyelesaian dalam hal terjadi perselisihan.",
                    children: [
                      VoidTextField(controller: kantorPialangBerjangka, fieldName: "Kantor Cabang Pialang Berjangka", hintText: "Kantor Cabang Pialang Berjangka", labelText: "Kantor Cabang Pialang Berjangka", onPressed: () async {
                        CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Kantor Cabang Pialang Berjangka", children: List.generate(GlobalVariable.kantorCabangBerjangka.length, (i){
                          return ListTile(
                            onTap: (){
                              Navigator.pop(context);
                              kantorPialangBerjangka.text = GlobalVariable.kantorCabangBerjangka[i];
                            },
                            title: Text(GlobalVariable.kantorCabangBerjangka[i], style: GoogleFonts.inter()),
                          );
                        }));
                      }),
                    ]
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => StepUtilities.stepOnlineRegister(
              size: size,
              title: regolController.isLoading.value ? "Proceessing..." : "Penyelesaian Perselisihan",
              onPressed: regolController.isLoading.value ? null : (){
                if(selectedPerselisihan.value == ""){
                  CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon pilih tempat perselisihan");
                  return;
                }
                regolController.postPenyelasaianMasalah(
                  kantorPenyelesaianMasalah: selectedPerselisihan.value,
                  kotaPenyelesaianMasalah: kantorPialangBerjangka.text
                ).then((result){
                  if(result){
                    Get.to(() => const Step14KelengkapanDokumenPerusahaan());
                  }
                });
              },
              progressEnd: 4,
              currentAllPageStatus: 3,
              progressStart: 3
          ),
        ),
      ),
    );
  }
}

