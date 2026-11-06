import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/website.dart';
import '../storage/session_manager.dart';

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final user = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String;
      await SessionManager.saveSession(
        token: token,
        userId: user['id'] as String,
        name: user['name'] as String,
        email: user['email'] as String,
      );
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Login failed (${response.statusCode})',
      );
    }
  }

  static Future<List<Project>> getProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/projects'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['data'] as List)
          .map((e) => Project.fromJson(e))
          .toList();
      return list;
    }
    return [];
  }

  static Future<List<Website>> getWebsites() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/websites'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['data'] as List)
          .map((e) => Website.fromJson(e))
          .toList();
      return list;
    }
    return [];
  }

  static Future<Website> createWebsite(
    String name,
    String projectId, {
    Map<String, dynamic>? document,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'project_id': projectId,
      'document': ?document,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/websites'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return Website.fromJson(data['website']);
    } else {
      throw Exception('Failed to create website (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> getWebsiteDetails(
    String websiteId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to load website details (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> updateWebsiteDocument(
    String websiteId,
    Map<String, dynamic> document,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/document'),
      headers: await _headers(),
      body: jsonEncode({'document': document, 'source': 'manual'}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update document (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> aiEdit({
    required String websiteId,
    required String instruction,
    String? targetSectionId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/ai/edit'),
      headers: await _headers(),
      body: jsonEncode({
        'website_id': websiteId,
        'instruction': instruction,
        'target_section_id': ?targetSectionId,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'AI Edit failed (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> generateWebsite({
    required String prompt,
    required String projectId,
    String? industry,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/ai/generate'),
      headers: await _headers(),
      body: jsonEncode({
        'prompt': prompt,
        'project_id': projectId,
        'industry': ?industry,
        'sync': true,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Generation failed (${response.statusCode})',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getTemplates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/templates'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['data'] as List).cast<Map<String, dynamic>>();
      return list;
    }
    return [];
  }

  static Future<Website> useTemplate({
    required String templateId,
    required String projectId,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/templates/$templateId/use'),
      headers: await _headers(),
      body: jsonEncode({'project_id': projectId, 'name': name}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Website.fromJson(data['website']);
    } else {
      throw Exception(
        data['message'] ?? 'Failed to use template (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> publishWebsite(String websiteId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/publish'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Publishing failed (${response.statusCode})',
      );
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/v1/auth/logout'),
        headers: await _headers(),
      );
    } catch (_) {}
    await SessionManager.clearSession();
  }
}
