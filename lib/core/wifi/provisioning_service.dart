// lib/features/provisioning/provisioning_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProvisioningService {
  static const _espUrl = 'http://192.168.4.1';

  static Future<Map<String, dynamic>> status() async {
    final r = await http.get(Uri.parse('$_espUrl/status')).timeout(const Duration(seconds: 5));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<bool> provision({required String ssid, required String pass}) async {
    final body = jsonEncode({'ssid': ssid, 'pass': pass});
    final r = await http.post(
      Uri.parse('$_espUrl/provision'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 5));
    if (r.statusCode == 200) return true;
    return false;
  }
}
