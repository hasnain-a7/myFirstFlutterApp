import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialPosition = CameraPosition(
    target: LatLng(24.8607, 67.0011), // Karachi location
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                "Navigation",
                style: TextStyle(color: Colors.white, fontSize: 24),
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
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
