import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List> users;
  String userName = "";
  String userEmail = "";
  String profilePic = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
    loadUserData();
  }

  void fetchUsers() {
    setState(() {
      users = ApiService.getUsers();
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('name') ?? 'Guest';
      userEmail = prefs.getString('email') ?? 'guest@example.com';
      profilePic =
          prefs.getString('profile_pic') ??
          'https://dev.hasnain.site/api/uploads/wallpaperflare.com_wallpaper.jpg';
    });
  }

  Future<void> deleteUser(String email) async {
    final res = await ApiService.deleteUser(email);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res["message"] ??
              (res["success"] == true
                  ? "User deleted successfully"
                  : "Failed to delete user"),
        ),
        backgroundColor: res["success"] == true
            ? Colors.green
            : Colors.redAccent,
      ),
    );

    if (res["success"] == true) fetchUsers();
  }

  Future<void> handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _launchGitHub() async {
    const url = 'https://github.com/hasnain-a7/myFirstFlutterApp';
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF009688), Color(0xFF26C6DA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Hi, $userName 👋",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.code, color: Colors.white),
            onPressed: _launchGitHub,
            tooltip: "View on GitHub",
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: () => handleLogout(context),
          ),
        ],
      ),

      // Drawer
      drawer: Drawer(
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF009688), Color(0xFF26C6DA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(profilePic),
                radius: 40,
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
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),

      // Body
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List>(
          future: users,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return RefreshIndicator(
                color: Colors.teal,
                onRefresh: () async => fetchUsers(),
                child: ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: Text(
                        "No users found 😕",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final userList = snapshot.data!;
            return RefreshIndicator(
              color: Colors.teal,
              onRefresh: () async => fetchUsers(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userList.length,
                itemBuilder: (context, i) {
                  final user = userList[i];
                  final timestamp = user['created_at'] ?? "";
                  String formattedTime = "";

                  if (timestamp.isNotEmpty) {
                    try {
                      final dateTime = DateTime.parse(timestamp);
                      formattedTime = DateFormat(
                        'MMM d, yyyy • hh:mm a',
                      ).format(dateTime);
                    } catch (_) {
                      formattedTime = "Invalid date";
                    }
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(2, 3),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          user['profile_pic'] ?? 'assets/2.jpg',
                        ),
                      ),
                      title: Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['email'],
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Joined: $formattedTime",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.teal,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                "Delete User",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                "Are you sure you want to delete ${user['name']}?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) await deleteUser(user['email']);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
