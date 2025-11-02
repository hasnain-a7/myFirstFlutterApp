import 'package:flutter/material.dart';
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
    const url =
        'https://github.com/hasnain-a7/myFirstFlutterApp.git'; // replace with your GitHub URL
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Welcome, $userName",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.code), // GitHub-like icon
            onPressed: _launchGitHub,
            tooltip: "GitHub",
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.teal, Colors.cyan]),
              ),
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: profilePic.isNotEmpty
                    ? NetworkImage(profilePic)
                    : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/gallery');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text('Map'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/map');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                      handleLogout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List>(
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
                      "No users found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
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
              padding: const EdgeInsets.all(12),
              itemCount: userList.length,
              itemBuilder: (context, i) {
                final user = userList[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  shadowColor: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.teal.shade200,
                      backgroundImage: (user['profile_pic'] != null)
                          ? NetworkImage(user['profile_pic'])
                          : const NetworkImage(
                              'https://dev.hasnain.site/api/uploads/wallpaperflare.com_wallpaper.jpg',
                            ),
                    ),
                    title: Text(
                      user['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(user['email']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete User"),
                            content: Text(
                              "Are you sure you want to delete ${user['name']}?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
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
    );
  }
}
