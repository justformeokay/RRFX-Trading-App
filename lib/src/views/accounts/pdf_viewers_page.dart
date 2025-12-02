import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // 1. Request Storage Permissions
      PermissionStatus status = await Permission.storage.status;

      if (status.isDenied) {
        // If permission is denied, request it
        status = await Permission.storage.request();
      }

      if (status.isPermanentlyDenied) {
        // If permission is permanently denied, direct user to app settings
        setState(() {
          isLoading = false;
          errorMessage = 'Storage permission permanently denied. Please enable it in app settings.';
        });
        // Optionally, open settings directly for the user
        await openAppSettings();
        return;
      }

      if (!status.isGranted) {
        // If permission is still not granted after request (e.g., user denied it)
        setState(() {
          isLoading = false;
          errorMessage = 'Storage permission denied. Cannot save PDF.';
        });
        // print('Storage permission denied.');
        return; // Stop if permission is not granted
      }

      // 2. Get the public Downloads directory
      final Directory? externalDir = await getDownloadsDirectory();

      if (externalDir == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Could not access external storage directory.';
        });
        // print('Could not access external storage directory.');
        return;
      }

      final String saveDirectory = externalDir.path;
      // Ensure the directory exists
      if (!await Directory(saveDirectory).exists()) {
        await Directory(saveDirectory).create(recursive: true);
      }

      // 3. Define the file path in the public directory
      String sanitizedTitle = widget.title.replaceAll(RegExp(r'[^\w\s.-]'), '_');
      final String fileName = p.setExtension(sanitizedTitle, '.pdf');
      final filePath = p.join(saveDirectory, fileName);

      // 4. Download the file and replace if exists
      // print('Attempting to download PDF to: $filePath');
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          localPath = filePath;
          isLoading = false;
        });
        // print('PDF downloaded and replaced at: $localPath');
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load PDF: ${response.statusCode}';
        });
        // print('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
      // print('Error downloading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage != null
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              if (errorMessage!.contains('permanently denied'))
                ElevatedButton(
                  onPressed: () {
                    openAppSettings(); // Open app settings for the user
                  },
                  child: const Text('Open App Settings'),
                ),
            ],
          ),
        )
            : localPath != null
            ? PDFView(
          filePath: localPath!,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          // onRender: (_pages) {
          //   // print("Total pages: $_pages");
          // },
          onError: (error) {
            // print(error.toString());
            setState(() {
              errorMessage = 'Error displaying PDF: ${error.toString()}';
            });
          },
          onPageError: (page, error) {
            // print('$page: ${error.toString()}');
          },
          onViewCreated: (PDFViewController vc) {
            // Controller bisa disimpan jika diperlukan
          },
        )
            : const Text("No PDF to display."),
      ),
    );
  }
}