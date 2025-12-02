import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';
import '../controllers/document_controller.dart';
import '../models/document_model.dart';

// 1. Ubah ke StatefulWidget
class DocumentListPage extends StatefulWidget {
  const DocumentListPage({super.key, this.loginID});
  final String? loginID;

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

// 2. Buat State Class
class _DocumentListPageState extends State<DocumentListPage> {
  late final DocumentController documentController;

  @override
  void initState() {
    super.initState();
    documentController = Get.put(DocumentController());
    if (widget.loginID != null) {
      documentController.fetchDocuments(loginID: widget.loginID!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = documentController; 
    final isDarkMode = Get.isDarkMode;
    final primaryColor = CustomColor.secondaryColor;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dokumen Saya",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      // 5. Gunakan Obx untuk reaktif terhadap perubahan controller
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
        }
        if (controller.documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text("Tidak ada dokumen yang tersedia saat ini."),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: (){
                    // Panggil ulang dengan loginID saat Coba Muat Ulang
                    controller.fetchDocuments(loginID: widget.loginID);
                  }, 
                  child: const Text("Coba Muat Ulang"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.documents.length,
          itemBuilder: (context, index) {
            final doc = controller.documents[index];
            return _buildDocumentCard(context, doc, controller, cardColor);
          },
        );
      }),
    );
  }

  // Widget _buildDocumentCard dipindahkan ke luar build method atau dijadikan private
  // dan diakses dari State Class
  Widget _buildDocumentCard(
    BuildContext context, 
    Document doc, 
    DocumentController controller, 
    Color cardColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          Icons.picture_as_pdf, 
          color: CustomColor.secondaryColor, 
          size: 35
        ),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Tipe: PDF Document',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        onTap: () => controller.viewDocument(doc),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              controller.viewDocument(doc);
            } else if (value == 'download') {
              controller.downloadDocument(doc);
            } else if (value == 'share') {
              controller.shareDocument(doc);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Lihat Dokumen'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'download',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Unduh PDF'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Bagikan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}