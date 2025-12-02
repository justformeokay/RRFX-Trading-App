import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerPage extends StatelessWidget {
  final String? imageUrl; // Can be a network URL or a local file path
  final String title;

  const ImageViewerPage({
    super.key,
    required this.imageUrl,
    this.title = 'Image Viewer', // Default title
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      backgroundColor: Colors.black, // Dark background for the image
      body: Center(
        // InteractiveViewer allows zooming and panning
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(0.0), // Margin around the image content
          minScale: 0.1, // Minimum zoom scale
          maxScale: 4.0, // Maximum zoom scale
          child: _buildImageWidget(),
        ),
      ),
    );
  }

  // Helper method to decide whether to load from network or file
  Widget _buildImageWidget() {
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      // It's a network image
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red, size: 50),
        fit: BoxFit.contain, // Ensure the whole image is visible initially
      );
    } else if (File(imageUrl!).existsSync()) {
      // It's a local file path and the file exists
      return Image.file(
        File(imageUrl!),
        fit: BoxFit.contain,
      );
    } else {
      // Invalid URL or local file not found
      return const Icon(Icons.image_not_supported, color: Colors.grey, size: 100);
    }
  }
}