import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://dev.hasnain.site/api";

  // ------------------ LOGIN ------------------
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // ------------------ REGISTER ------------------
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String? imagePath,
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/register.php");
      var request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;

      // Add image if selected
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          File(imagePath).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', imagePath),
        );
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        return {
          "success": false,
          "message": "Server Error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // ------------------ FETCH USERS ------------------
  static Future<List> getUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users.php"));
    final data = jsonDecode(response.body);
    return data['users'] ?? [];
  }

  // ------------------ DELETE USER ------------------
  static Future<Map<String, dynamic>> deleteUser(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delUser.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"success": false, "message": "Server error"};
    }
  }
}
