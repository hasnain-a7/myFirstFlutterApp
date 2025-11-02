import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker picker = ImagePicker();
  XFile? image;

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = picked);
  }

  @override
  Widget build(BuildContext context) {
    Widget displayImage() {
      if (image == null) {
        return const Text("No image selected");
      } else if (kIsWeb) {
        // For Web, use Image.network
        return Image.network(
          image!.path,
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        );
      } else {
        // For Mobile, use Image.file
        return Image.file(
          File(image!.path),
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Gallery")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            displayImage(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),
          ],
        ),
      ),
    );
  }
}
