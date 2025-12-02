import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../controllers/document_controller.dart';
import '../models/document_model.dart';

class PdfViewerPage extends GetView<DocumentController> {
  final Document document;
  const PdfViewerPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final DocumentController c = Get.find<DocumentController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    final iconColor = Theme.of(context).colorScheme.onSurface; 
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        title: Text(
          document.name,
          style: GoogleFonts.inter(
            fontSize: 14, 
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: iconColor),
            tooltip: 'Unduh PDF',
            onPressed: () => c.downloadDocument(document),
          ),
          IconButton(
            icon: Icon(Icons.share, color: iconColor),
            tooltip: 'Bagikan Dokumen',
            onPressed: () => c.shareDocument(document),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // PDF Viewer Dengan Warna Loading Indicator Kustom
      body: SfPdfViewer.network(
        document.link,
        canShowPageLoadingIndicator: true,
      ),
    );
  }
}
