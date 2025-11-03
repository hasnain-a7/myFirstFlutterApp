import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  String userName = "Guest";

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('name') ?? 'Guest';
    });
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = picked);
  }

  Widget displayImage() {
    if (image == null) {
      return const Text(
        "No image selected",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    } else if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          image!.path,
          height: 180,
          width: 180,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(image!.path),
          height: 180,
          width: 180,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gallery",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.teal, Colors.cyan]),
              ),
              accountName: Text(userName),
              accountEmail: const Text("Gallery Section"),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/BATMAN.jpg'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.teal),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Colors.teal,
              ),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/gallery');
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined, color: Colors.teal),
              title: const Text("Map"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/map');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.teal,
              ),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("🌐 Online Images"),
            _imageGrid([
              'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d',
              'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
              'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
            ]),
            const SizedBox(height: 25),

            _sectionTitle("🖼 Local Images"),
            _imageGrid([
              'assets/1.jpg',
              'assets/2.jpg',
              'assets/BATMAN.jpg',
            ], local: true),
            const SizedBox(height: 25),

            _sectionTitle("📸 Pick from Gallery"),
            const SizedBox(height: 10),
            Center(child: displayImage()),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pickImage,
        label: const Text("Pick Image"),
        icon: const Icon(Icons.add_photo_alternate),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    ),
  );

  Widget _imageGrid(List<String> images, {bool local = false}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.teal.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: images.map((src) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: local
                  ? Image.asset(src, height: 130, width: 130, fit: BoxFit.cover)
                  : Image.network(
                      src,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
