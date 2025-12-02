import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LocalPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const LocalPdfViewer({super.key, required this.pdfUrl, required this.title});

  @override
  State<LocalPdfViewer> createState() => _LocalPdfViewerState();
}

class _LocalPdfViewerState extends State<LocalPdfViewer> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
              ? const Center(child: Text("Failed to load PDF"))
              : PDFView(filePath: localPath!),
    );
  }
}
