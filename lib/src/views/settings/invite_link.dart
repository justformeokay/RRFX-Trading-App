import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:share_plus/share_plus.dart';

class InviteLink extends StatefulWidget {
  const InviteLink({super.key});

  @override
  State<InviteLink> createState() => _InviteLinkState();
}

class _InviteLinkState extends State<InviteLink> {
  final UtilitiesController utilitiesController = Get.put(UtilitiesController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      utilitiesController.getRefferalLinks().then((onValue) {
        if (!onValue) {
          return;
        }
      });
    });
  }

  // Fungsi untuk menyalin teks ke clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link berhasil disalin! ✅'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tautan Referral'),
        elevation: 0,
      ),
      body: Obx(() {
          if(utilitiesController.inviteLinkModel.value?.data?.general == null){
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Clarity.trash_line, size: 35.0),
                  const SizedBox(height: 10.0),
                  Text(utilitiesController.responseMessage.value)
                ],
              ),
            );
          }
          if(utilitiesController.inviteLinkModel.value?.data?.general?.isEmpty == true){
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Clarity.trash_line, size: 35.0),
                  const SizedBox(height: 10.0),
                  Text(utilitiesController.responseMessage.value)
                ],
              ),
            );
          }
          final inviteModel = utilitiesController.inviteLinkModel.value;

          if (inviteModel == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final inviteData = inviteModel.data;

          if (inviteData == null || ((inviteData.general?.isEmpty ?? true) && (inviteData.spesific?.isEmpty ?? true))) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    utilitiesController.responseMessage.value.isNotEmpty
                      ? utilitiesController.responseMessage.value
                      : "Tidak ada referral yang tersedia.",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tautan Referral Umum',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReferralList(inviteData.general ?? []),

                const SizedBox(height: 32),

                const Text(
                  'Tautan Referral Spesifik',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReferralList(inviteData.spesific ?? []),
              ],
            ),
          );
        })
    );
  }

 // Widget pembangun untuk daftar tautan
  Widget _buildReferralList(List? links) {
    if (links == null || links.isEmpty) {
      return const Text(
        "Tidak ada data referral.",
        style: TextStyle(color: Colors.white70),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: links.length,
      itemBuilder: (context, index) {
        final linkData = links[index];
        final String name = linkData.name ?? "-";
        final String link = linkData.link ?? "";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              link,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blueAccent),
                  onPressed: () {
                    if (link.isNotEmpty) {
                      _copyToClipboard(link);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.green),
                  onPressed: () {
                    if (link.isNotEmpty) {
                      SharePlus.instance.share(
                        ShareParams(text: '🎉 Yuk gabung ke Platform RRFX menggunakan tautan referral saya: $link')
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
