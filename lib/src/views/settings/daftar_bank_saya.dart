import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/models/utilities/list_bank_user.dart';
import 'package:rrfx/src/views/settings/informasi_detail_bank_saya.dart';

class DaftarBankSaya extends StatefulWidget {
  const DaftarBankSaya({super.key});

  @override
  State<DaftarBankSaya> createState() => _DaftarBankSayaState();
}

class _DaftarBankSayaState extends State<DaftarBankSaya> {
  
  RxList<ListBankUserV2> bankDummy = <ListBankUserV2>[].obs;
  SettingController settingController = Get.put(SettingController());
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      settingController.getUserBank().then((resultBank){
        if(!resultBank){
          CustomScaffoldMessanger.showAppSnackBar(context, message: settingController.responseMessage.value, type: SnackBarType.error);
          return;
        }
        if(settingController.userBankModel.value?.response == null || settingController.userBankModel.value?.response?.isEmpty == true){
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Daftar Bank",
        autoImplyLeading: true
      ),
      body: RefreshIndicator(
        color: CustomColor.secondaryColor,
        onRefresh: () async {
          await settingController.getUserBank().then((resultBank){
            if(!resultBank){
              CustomScaffoldMessanger.showAppSnackBar(context, message: settingController.responseMessage.value, type: SnackBarType.error);
              return;
            }
            if(settingController.userBankModel.value?.response == null || settingController.userBankModel.value?.response?.isEmpty == true){
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
              children: [
                Obx(
                  () {
                    if (settingController.isLoading.value) {
                      return SizedBox(
                        width: size.width,
                        height: size.height / 1.2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/json/loader.json'),
                            const SizedBox(height: 16),
                            const Text("Mendapatkan Informasi Anda"),
                          ],
                        ),
                      );
                    }
        
                    final response = settingController.userBankModel.value?.response;
        
                    if (response == null || response.isEmpty) {
                      return SizedBox(
                        width: size.width,
                        height: size.height / 1.2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/json/cat.json'),
                            const SizedBox(height: 16),
                            const Text("Tidak ada informasi bank anda"),
                          ],
                        ),
                      );
                    }
        
                    return UtilitiesWidget.titleContent(
                      title: "Daftar Bank",
                      subtitle: "Semua Daftar Rekening Bank anda ada disini",
                      children: List.generate(
                        response.length,
                        (i) {
                          return ListTile(
                            onTap: (){
                              if(response[i].statusString == "Pending"){
                                CustomScaffoldMessanger.showAppSnackBar(context, message: "Bank belum diverifikasi oleh admin.");
                              }else if(response[i].statusString == "Aktif"){
                                Get.to(() => InformasiDetailBankSaya(
                                  editingMode: false,
                                  editDitolakMode: false,
                                  bankName: response[i].name ?? "-",
                                  bankNumber: response[i].account ?? "-",
                                ));
                              }else if(response[i].statusString == "Ditolak"){
                                Get.to(() => InformasiDetailBankSaya(
                                  editingMode: true,
                                  editDitolakMode: true,
                                  idBankEditingMode: settingController.userBankModel.value?.response?[i].id,
                                  bankName: response[i].name ?? "-",
                                  bankNumber: response[i].account ?? "-",
                                ));
                              }else{
                                CustomScaffoldMessanger.showAppSnackBar(context, message: "Status tidak diketahui");
                              }
                            },
                            onLongPress: () async {
                              final selected = await showMenu<String>(
                                context: context,
                                position: RelativeRect.fromLTRB(200, 200, 0, 0), // posisi popup
                                items: [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text("Edit"),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text("Hapus"),
                                      ],
                                    ),
                                  ),
                                ],
                              );
        
                              if (selected == 'edit') {
                                Get.to(() => InformasiDetailBankSaya(
                                  editingMode: true,
                                  bankName: response[i].name ?? "-",
                                  bankNumber: response[i].account ?? "-",
                                ));
                              } else if (selected == 'delete') {
                                Get.defaultDialog(
                                  title: "Hapus Bank",
                                  middleText: "Apakah anda yakin ingin menghapus Bank ${response[i].name} dengan nomor rekening ${response[i].account}",
                                  textCancel: "Batal",
                                  textConfirm: "Yakin",
                                  buttonColor: CustomColor.secondaryBackground,
                                  cancelTextColor: CustomColor.secondaryBackground,
                                  confirmTextColor: Colors.black,
                                  onCancel: (){},
                                  onConfirm: (){}
                                );
                              }
                            },
                            leading: Container(
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade600,
                              ),
                              child: Text(
                                "${i + 1}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                            minLeadingWidth: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            title: Text(
                              response[i].name ?? "-",
                              style: TextStyle(fontWeight: FontWeight.w700),
                              maxLines: 1,
                            ),
                            subtitle: Text("No. Rekening : ${response[i].account ?? "-"}"),
                            trailing: Obx(() {
                              if (isLoading.value) {
                                return const SizedBox();
                              }
                              Color? color;
                              switch(response[i].statusString){
                                case "Aktif":
                                  color = Colors.green.shade400;
                                  break;
                                case "Pending":
                                  color = Colors.blueAccent.shade400;
                                  break;
                                case "Not Verified":
                                  color = Colors.orange.shade400;
                                  break;
                                case "Ditolak":
                                  color = Colors.red.shade400;
                                  break;
                                default:
                                  color = Colors.grey.shade400;
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: color,
                                ),
                                child: Text(
                                  response[i].statusString ?? 'Unknown',
                                  style: TextStyle(fontSize: 9.0, color: response[i].statusString == "Verified" ? Colors.black : Colors.white),
                                ),
                              );
                            }),
                          );
                        }
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      floatingActionButton: Obx(
        () => FloatingActionButton.small(
          onPressed: settingController.isLoading.value ? null : (){
            if(settingController.userBankModel.value?.response?.length == 2){
              CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda tidak dapat menambah bank karena sudah mencapai limit maksimal");
              return;
            }
            Get.to(() => const InformasiDetailBankSaya(editingMode: true));
          },
          backgroundColor: CustomColor.secondaryColor,
          child: Icon(Clarity.add_line)
        ),
      ),
    );
  }
}