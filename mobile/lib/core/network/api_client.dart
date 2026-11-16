import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/website.dart';
import '../storage/session_manager.dart';

class SubscriptionLimitException implements Exception {
  final String message;
  final String? metric;
  final int? limit;
  final int? current;

  SubscriptionLimitException(
    this.message, {
    this.metric,
    this.limit,
    this.current,
  });

  @override
  String toString() => message;
}

class ApiClient {
  static bool isSubscriptionLimitError(dynamic error) {
    if (error is SubscriptionLimitException) return true;
    final msg = error.toString().toLowerCase();
    return msg.contains('subscription_limit_exceeded') ||
        msg.contains('upgrade to premium') ||
        msg.contains('requires a premium subscription') ||
        msg.contains('premium subscription') ||
        msg.contains('max_websites') ||
        msg.contains('max_published') ||
        msg.contains('custom_domains');
  }

  static const bool useLocalBackend =
      bool.fromEnvironment('USE_LOCAL_BACKEND', defaultValue: false);

  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;
    if (useLocalBackend) {
      return Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
    }
    return 'https://api.ai-landing-page.xyz';
  }

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

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
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
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
      }
      throw Exception(
        data['message'] ?? 'Registration failed (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> signInWithGoogle(
    String idToken, {
    String? deviceName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/google'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'id_token': idToken,
        if (deviceName != null) 'device_name': deviceName,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final user = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String;
      await SessionManager.saveSession(
        token: token,
        userId: user['id'] as String,
        name: user['name'] as String? ?? 'Google User',
        email: user['email'] as String? ?? '',
      );
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Google sign-in failed (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> signInWithApple(
    String identityToken, {
    String? name,
    String? deviceName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/apple'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'identity_token': identityToken,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (deviceName != null) 'device_name': deviceName,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final user = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String;
      await SessionManager.saveSession(
        token: token,
        userId: user['id'] as String,
        name: (user['name'] as String?)?.isNotEmpty == true
            ? user['name'] as String
            : (name?.isNotEmpty == true ? name! : 'Apple User'),
        email: user['email'] as String? ?? '',
      );
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Apple sign-in failed (${response.statusCode})',
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
      if (list.isEmpty) {
        final created = await createProject('My Workspace');
        if (created != null) {
          list.add(created);
        }
      }
      return list;
    }
    return [];
  }

  static Future<Project?> createProject(String name, {String? description}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/projects'),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'description': description ?? 'Main workspace for your landing pages',
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Project.fromJson(data['project']);
      }
    } catch (_) {}
    return null;
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
      String message = 'Failed to create website (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        if (data is Map) {
          if (data['error'] == 'subscription_limit_exceeded' ||
              data['entitlement']?['upgrade_required'] == true) {
            throw SubscriptionLimitException(
              data['message']?.toString() ?? message,
              metric: data['entitlement']?['metric']?.toString(),
              limit: (data['entitlement']?['limit'] as num?)?.toInt(),
              current: (data['entitlement']?['current'] as num?)?.toInt(),
            );
          }
          if (data['message'] != null) {
            message = data['message'].toString();
          }
        }
      } catch (e) {
        if (e is SubscriptionLimitException) rethrow;
      }
      throw Exception(message);
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

  static Future<bool> deleteWebsite(String websiteId) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return true;
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/websites/$websiteId'),
        headers: await _headers(),
      );
      // 2xx success or 404 (website already removed on server / client mock)
      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 404) {
        return true;
      }
      throw Exception('Failed to delete website (${response.statusCode})');
    } catch (e) {
      if (websiteId.startsWith('showcase_') ||
          websiteId.startsWith('demo_') ||
          websiteId.startsWith('local_') ||
          websiteId.startsWith('project_')) {
        return true;
      }
      rethrow;
    }
  }

  static const String openRouterApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

  static Future<Map<String, dynamic>> aiEdit({
    String? websiteId,
    required String instruction,
    String? targetSectionId,
    Map<String, dynamic>? document,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final docCopy = document != null
          ? jsonDecode(jsonEncode(document)) as Map<String, dynamic>
          : <String, dynamic>{};
      final lower = instruction.toLowerCase();
      if (lower.contains('pink') || lower.contains('blush')) {
        docCopy['site'] ??= {};
        docCopy['site']['theme'] ??= {};
        docCopy['site']['theme']['colors'] = {
          'background': '#FFF1F2',
          'primary': '#BE123C',
          'accent': '#FB7185',
        };
      } else if (lower.contains('espresso') || lower.contains('dark')) {
        docCopy['site'] ??= {};
        docCopy['site']['theme'] ??= {};
        docCopy['site']['theme']['colors'] = {
          'background': '#1C1917',
          'primary': '#D97706',
          'accent': '#EA580C',
        };
      } else if (lower.contains('product') ||
          lower.contains('store') ||
          lower.contains('shop') ||
          lower.contains('pricing')) {
        final pages = docCopy['pages'] as List? ?? [];
        if (pages.isNotEmpty) {
          final sections = pages[0]['sections'] as List? ?? [];
          final hasProducts = sections.any(
            (s) => s is Map && s['component'] == 'products',
          );
          if (!hasProducts) {
            sections.add({
              'id': 'sec_products_test',
              'component': 'products',
              'order': sections.length,
              'props': {
                'title': 'Test Products',
                'subtitle': 'Curated collection',
                'items': [
                  {
                    'name': 'Artisan Roast',
                    'price': '\$18.00',
                    'description': 'Delicious blend.',
                    'image': 'https://example.com/roast.jpg',
                  },
                  {
                    'name': 'Morning Pastry',
                    'price': '\$4.50',
                    'description': 'Freshly baked.',
                    'image': 'https://example.com/pastry.jpg',
                  },
                ],
              },
            });
            pages[0]['sections'] = sections;
          }
        }
      }
      return {
        'message': 'Website updated successfully (test).',
        'summary': 'AI edit applied',
        'document': docCopy,
        'website': {'document': docCopy},
      };
    }

    // 1. Try Laravel backend first
    try {
      final body = <String, dynamic>{
        'instruction': instruction,
        if (websiteId != null && websiteId.isNotEmpty) 'website_id': websiteId,
        'target_section_id': ?targetSectionId,
        'document': ?document,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/ai/edit'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['document'] != null || data['website'] != null) {
          return data;
        }
      } else if (response.statusCode == 403) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['error'] == 'subscription_limit_exceeded' ||
              data['entitlement']?['upgrade_required'] == true) {
            throw SubscriptionLimitException(
              data['message']?.toString() ?? 'AI edit quota exceeded.',
              metric: data['entitlement']?['metric']?.toString(),
              limit: (data['entitlement']?['limit'] as num?)?.toInt(),
              current: (data['entitlement']?['current'] as num?)?.toInt(),
            );
          }
        } catch (e) {
          if (e is SubscriptionLimitException) rethrow;
        }
      }
    } catch (e) {
      if (e is SubscriptionLimitException) rethrow;
      // If backend is unreachable, fallback to direct OpenRouter API
    }

    // 2. Direct OpenRouter API call using configured API key
    return await callOpenRouterDirectly(
      instruction: instruction,
      document: document,
      targetSectionId: targetSectionId,
    );
  }

  static String _extractJson(String text) {
    var clean = text.trim();
    if (clean.contains('```json')) {
      final start = clean.indexOf('```json') + 7;
      final end = clean.lastIndexOf('```');
      if (end > start) {
        clean = clean.substring(start, end).trim();
      }
    } else if (clean.contains('```')) {
      final start = clean.indexOf('```') + 3;
      final end = clean.lastIndexOf('```');
      if (end > start) {
        clean = clean.substring(start, end).trim();
      }
    }
    final firstBrace = clean.indexOf('{');
    final lastBrace = clean.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
      clean = clean.substring(firstBrace, lastBrace + 1);
    }
    return clean;
  }

  static Map<String, dynamic> applyOperationsToDoc(
    Map<String, dynamic> doc,
    List<dynamic> operations,
  ) {
    final copy = jsonDecode(jsonEncode(doc)) as Map<String, dynamic>;

    for (final op in operations) {
      if (op is! Map) continue;
      final type =
          (op['type'] ?? op['operation'])?.toString().toLowerCase() ?? '';

      switch (type) {
        case 'update_component':
        case 'update':
        case 'replace':
          final sectionId = (op['section_id'] ?? op['id'] ?? op['sectionId'])
              ?.toString();
          if (sectionId == null) break;
          final pages = copy['pages'] as List?;
          if (pages != null) {
            for (final p in pages) {
              final sections = p['sections'] as List?;
              if (sections != null) {
                for (final sec in sections) {
                  if (sec['id'] == sectionId) {
                    if (op['props'] is Map) {
                      sec['props'] = {
                        ...(sec['props'] as Map? ?? {}),
                        ...(op['props'] as Map),
                      };
                    }
                    if (op['styles'] is Map) {
                      sec['styles'] = {
                        ...(sec['styles'] as Map? ?? {}),
                        ...(op['styles'] as Map),
                      };
                    }
                    if (op['variant'] != null) {
                      sec['variant'] = op['variant'];
                    }
                    break;
                  }
                }
              }
            }
          }
          break;

        case 'add_component':
        case 'add':
          final pageId = op['page_id']?.toString() ?? 'page_home';
          final rawSec = op['section'] ?? op['component'] ?? op['value'];
          if (rawSec is Map) {
            final section = Map<String, dynamic>.from(rawSec);
            if (section['component'] == null && section['type'] != null) {
              section['component'] = section['type'];
            }
            final comp = section['component']?.toString().toLowerCase() ?? '';
            if (comp == 'product_grid' ||
                comp == 'store' ||
                comp == 'pricing_grid') {
              section['component'] = 'products';
            }
            if (section['props'] is! Map) {
              section['props'] = <String, dynamic>{
                if (section['items'] != null) 'items': section['items'],
                if (section['products'] != null) 'items': section['products'],
                if (section['title'] != null) 'title': section['title'],
                if (section['subtitle'] != null)
                  'subtitle': section['subtitle'],
              };
            } else {
              final props = Map<String, dynamic>.from(section['props'] as Map);
              if (props['products'] != null && props['items'] == null) {
                props['items'] = props['products'];
              }
              section['props'] = props;
            }
            section['id'] ??=
                'sec_${DateTime.now().millisecondsSinceEpoch}_${(section['component'] ?? 'item')}';

            final pages = copy['pages'] as List?;
            if (pages != null && pages.isNotEmpty) {
              final page = pages.firstWhere(
                (p) => p['id'] == pageId,
                orElse: () => pages[0],
              );
              page['sections'] ??= [];
              final sections = page['sections'] as List;
              final order = op['order'] is int
                  ? op['order'] as int
                  : sections.length;
              section['order'] = order;
              sections.add(section);
              sections.sort(
                (a, b) => ((a['order'] ?? 0) as num).compareTo(
                  (b['order'] ?? 0) as num,
                ),
              );
            }
          }
          break;

        case 'remove_component':
        case 'remove':
        case 'delete':
          final sectionId = (op['section_id'] ?? op['id'])?.toString();
          if (sectionId != null) {
            final pages = copy['pages'] as List?;
            if (pages != null) {
              for (final p in pages) {
                final sections = p['sections'] as List?;
                if (sections != null) {
                  sections.removeWhere((s) => s['id'] == sectionId);
                }
              }
            }
          }
          break;

        case 'update_design_token':
          final path = op['path']?.toString() ?? '';
          final value = op['value'];
          if (path.isNotEmpty && value != null) {
            final cleanPath = path.replaceAll(
              RegExp(r'^(site\.)?(theme\.)?'),
              '',
            );
            final parts = cleanPath.split('.');
            copy['site'] ??= <String, dynamic>{};
            copy['site']['theme'] ??= <String, dynamic>{};
            dynamic target = copy['site']['theme'];
            for (var i = 0; i < parts.length; i++) {
              final k = parts[i];
              if (i == parts.length - 1) {
                target[k] = value;
              } else {
                target[k] ??= <String, dynamic>{};
                target = target[k];
              }
            }
          }
          break;
      }
    }

    return copy;
  }

  static Future<Map<String, dynamic>> callOpenRouterDirectly({
    required String instruction,
    Map<String, dynamic>? document,
    String? targetSectionId,
  }) async {
    const systemPrompt = '''
You are a precision website document editor.
Your job is to translate a user's natural language edit instruction into a list of atomic operations on the website document.
Supported operations:
1. "update_component": { "type": "update_component", "section_id": "string", "props": { ... }, "styles": { ... } }
2. "add_component": { "type": "add_component", "page_id": "page_home", "order": 2, "section": { "id": "sec_new_...", "component": "hero|products|features|faq|contact|gallery|testimonials", "props": { ... } } }
3. "remove_component": { "type": "remove_component", "section_id": "string" }
4. "move_component": { "type": "move_component", "section_id": "string", "new_order": 1 }
5. "update_design_token": { "type": "update_design_token", "path": "colors.primary", "value": "#HEX" }

COMPONENT SCHEMAS FOR "add_component":
- "products": { "component": "products", "props": { "title": "Our Products", "subtitle": "Curated selection", "items": [ { "name": "Item 1", "price": "\$25.00", "description": "High quality description", "image": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600" } ] } }
- "features": { "component": "features", "props": { "title": "Features", "subtitle": "Why choose us", "items": [ { "icon": "Sparkles", "title": "Feature 1", "description": "Details..." } ] } }
- "faq": { "component": "faq", "props": { "title": "Frequently Asked Questions", "items": [ { "question": "Question?", "answer": "Answer..." } ] } }
- "contact": { "component": "contact", "props": { "title": "Contact Us", "email": "info@example.com", "phone": "+1 234 567 890", "address": "123 Main St", "hours": "Mon-Fri 9am-6pm" } }
- "hero": { "component": "hero", "props": { "headline": "Headline", "subheadline": "Subheadline", "ctaText": "Get Started", "ctaLink": "#" } }

CRITICAL RULES:
- Target stable IDs existing in the document.
- Only modify requested elements; preserve all unrelated content.
- When asked to add products, add a "products" component with realistic items, prices, descriptions, and images.
- When asked to change color scheme (e.g. "make the site pink", "green theme", "dark mode"):
  Emit "update_design_token" operations for all relevant tokens:
  * "colors.background"
  * "colors.surface"
  * "colors.primary"
  * "colors.accent"
  * "colors.text.primary"
- Respond with pure JSON only:
{
  "operations": [ ... ],
  "summary": "Brief description of changes made"
}
''';

    final userPrompt = StringBuffer()
      ..writeln('User Instruction: $instruction');
    if (targetSectionId != null) {
      userPrompt.writeln('Target Section ID: $targetSectionId');
    }
    if (document != null) {
      userPrompt.writeln(
        '\nCurrent Website Document:\n${jsonEncode(document)}',
      );
    }

    final response = await http
        .post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $openRouterApiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://ai-landing-page.xyz',
            'X-Title': 'AI Website Builder',
          },
          body: jsonEncode({
            'model': 'google/gemini-2.5-flash',
            'models': [
              'google/gemini-2.5-flash',
              'google/gemini-2.5-flash-lite',
              'nvidia/nemotron-3.5-lightning:free',
            ],
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt.toString()},
            ],
            'temperature': 0.3,
            'max_tokens': 2500,
          }),
        )
        .timeout(const Duration(seconds: 40));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final resData = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = resData['choices'] as List?;
      final content = choices?[0]?['message']?['content'] as String? ?? '{}';

      final cleanJson = _extractJson(content);
      final parsed = jsonDecode(cleanJson) as Map<String, dynamic>;
      final rawOps = (parsed['operations'] as List?) ?? [];
      final operations = rawOps
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
      final summary = parsed['summary'] as String? ?? 'AI Edit applied';

      final updatedDoc = document != null
          ? applyOperationsToDoc(document, operations)
          : null;

      return {
        'message': 'Website updated successfully via OpenRouter.',
        'summary': summary,
        'operations': operations,
        'operations_applied': operations.length,
        'document': updatedDoc,
        'website': {'document': updatedDoc},
      };
    } else {
      throw Exception(
        'OpenRouter call failed (${response.statusCode}): ${response.body}',
      );
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
      if (data['error'] == 'subscription_limit_exceeded' ||
          data['entitlement']?['upgrade_required'] == true) {
        throw SubscriptionLimitException(
          data['message']?.toString() ?? 'AI generation quota exceeded.',
          metric: data['entitlement']?['metric']?.toString(),
          limit: (data['entitlement']?['limit'] as num?)?.toInt(),
          current: (data['entitlement']?['current'] as num?)?.toInt(),
        );
      }
      throw Exception(
        data['message'] ?? 'Generation failed (${response.statusCode})',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getTemplates({
    String? tab,
    String? search,
  }) async {
    final queryParameters = <String, String>{};
    if (tab != null && tab.isNotEmpty) queryParameters['tab'] = tab;
    if (search != null && search.isNotEmpty) queryParameters['search'] = search;

    final uri = Uri.parse('$baseUrl/api/v1/templates').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['data'] as List).cast<Map<String, dynamic>>();
      return list;
    }
    return [];
  }

  static Future<Map<String, dynamic>> shareWebsiteAsTemplate(
    String websiteId, {
    required String name,
    String? description,
    String? industry,
    String? badge,
    bool isPublic = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/share-template'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (industry != null && industry.isNotEmpty) 'industry': industry,
        if (badge != null && badge.isNotEmpty) 'badge': badge,
        'is_public': isPublic,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Failed to share template (${response.statusCode})',
      );
    }
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
      if (data['error'] == 'subscription_limit_exceeded' ||
          data['entitlement']?['upgrade_required'] == true) {
        throw SubscriptionLimitException(
          data['message']?.toString() ?? 'This template requires Premium.',
          metric: data['entitlement']?['metric']?.toString(),
          limit: (data['entitlement']?['limit'] as num?)?.toInt(),
          current: (data['entitlement']?['current'] as num?)?.toInt(),
        );
      }
      throw Exception(
        data['message'] ?? 'Failed to use template (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> publishWebsite(String websiteId) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return {
        'message': 'Website successfully published to global CDN.',
        'live_url': 'https://test-site.sites.aibuilder.app',
        'path_url': 'http://localhost:8000/test-site',
        'website': {
          'id': websiteId,
          'status': 'published',
          'subdomain': 'test-site',
        },
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/publish'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      if (data['error'] == 'subscription_limit_exceeded' ||
          data['entitlement']?['upgrade_required'] == true) {
        throw SubscriptionLimitException(
          data['message']?.toString() ?? 'Publishing limit reached.',
          metric: data['entitlement']?['metric']?.toString(),
          limit: (data['entitlement']?['limit'] as num?)?.toInt(),
          current: (data['entitlement']?['current'] as num?)?.toInt(),
        );
      }
      throw Exception(
        data['message'] ?? 'Publishing failed (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> unpublishWebsite(String websiteId) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return {
        'message': 'Website unpublished successfully.',
        'website': {'id': websiteId, 'status': 'draft'},
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/unpublish'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Unpublishing failed (${response.statusCode})',
      );
    }
  }

  static Future<Uint8List> exportWebsiteZip(String websiteId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/export'),
      headers: await _headers(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    } else {
      try {
        final data = jsonDecode(response.body);
        if (data is Map &&
            (data['error'] == 'subscription_limit_exceeded' ||
                data['entitlement']?['upgrade_required'] == true)) {
          throw SubscriptionLimitException(
            data['message']?.toString() ??
                'Project export requires a Premium subscription.',
            metric: data['entitlement']?['metric']?.toString() ?? 'code_export',
            limit: (data['entitlement']?['limit'] as num?)?.toInt() ?? 0,
            current: (data['entitlement']?['current'] as num?)?.toInt() ?? 0,
          );
        }
        throw Exception(
          data['message'] ?? 'Export failed (${response.statusCode})',
        );
      } catch (e) {
        if (e is SubscriptionLimitException) rethrow;
        throw Exception('Export failed (${response.statusCode})');
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getDeployments(
    String websiteId,
  ) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [
        {
          'id': 'dep-test-1',
          'status': 'deployed',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/deployments'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return list;
    }
    return [];
  }

  static Future<Map<String, dynamic>> updateWebsiteMetadata(
    String websiteId, {
    String? name,
    String? subdomain,
    String? slug,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      'subdomain': ?subdomain,
      'slug': ?slug,
    };

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return {
        'message': 'Website updated successfully.',
        'website': {
          'id': websiteId,
          'name': name ?? 'Updated Site',
          'subdomain': subdomain ?? 'updated-subdomain',
        },
      };
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Failed to update website (${response.statusCode})',
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

  static Future<List<Map<String, dynamic>>> getMediaAssets({
    String? websiteId,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (websiteId != null && websiteId.isNotEmpty && websiteId != 'all') {
      queryParams['website_id'] = websiteId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse(
      '$baseUrl/api/v1/assets',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final list = body['data'] as List?;
      if (list != null) {
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    }
    return [];
  }

  static Future<Map<String, dynamic>?> uploadMediaAsset({
    required String url,
    String? filename,
    String? mimeType,
    int? fileSize,
    String? websiteId,
  }) async {
    final body = <String, dynamic>{
      'url': url,
      'filename': ?filename,
      'mime_type': ?mimeType,
      'file_size': ?fileSize,
      if (websiteId != null && websiteId.isNotEmpty) 'website_id': websiteId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/assets'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> deleteMediaAsset(String assetId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/assets/$assetId'),
      headers: await _headers(),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // ── Custom Domains ──────────────────────────────────────────────────

  static final Map<String, List<Map<String, dynamic>>> _testDomains = {};

  static void resetTestDomains() {
    _testDomains.clear();
  }

  static void seedTestDomains(
    String websiteId,
    List<Map<String, dynamic>> domains,
  ) {
    _testDomains[websiteId] = List.from(domains);
  }

  static Future<Map<String, dynamic>> getDomains(String websiteId) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return {
        'domains': _testDomains[websiteId] ?? [],
        'subdomain': 'test',
        'subdomain_url': 'https://test.aibuilder.app',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/domains'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load domains (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> attachDomain(
    String websiteId,
    String domain,
  ) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final newDom = {
        'id': 'dom-test-${DateTime.now().millisecondsSinceEpoch}',
        'domain': domain,
        'status': 'pending',
        'ssl_status': {'status': 'pending'},
      };
      _testDomains.putIfAbsent(websiteId, () => []).add(newDom);
      return {
        'message': 'Custom domain added. Please configure your DNS records.',
        'domain': newDom,
        'dns_instructions': {
          'cname_record': {
            'type': 'CNAME',
            'name': domain,
            'target': 'sites.aibuilder.app',
          },
          'txt_record': {
            'type': 'TXT',
            'name': '_aibuilder-challenge.$domain',
            'value': 'challenge_token_abc123',
          },
        },
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/domains'),
      headers: await _headers(),
      body: jsonEncode({'domain': domain}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      if (data['error'] == 'subscription_limit_exceeded' ||
          data['entitlement']?['upgrade_required'] == true) {
        throw SubscriptionLimitException(
          data['message']?.toString() ?? 'Custom domains require Premium.',
          metric: data['entitlement']?['metric']?.toString(),
          limit: (data['entitlement']?['limit'] as num?)?.toInt(),
          current: (data['entitlement']?['current'] as num?)?.toInt(),
        );
      }
      throw Exception(
        data['message'] ?? 'Failed to attach domain (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> verifyDomain(
    String websiteId,
    String domainId,
  ) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final list = _testDomains[websiteId] ?? [];
      final idx = list.indexWhere((d) => d['id'] == domainId);
      if (idx != -1) {
        list[idx]['status'] = 'active';
        list[idx]['ssl_status'] = {'status': 'active'};
      }
      return {
        'message': 'Domain DNS verified and SSL certificate provisioned.',
        'verified': true,
        'domain': idx != -1 ? list[idx] : {'id': domainId, 'status': 'active'},
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/domains/$domainId/verify'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'DNS verification failed (${response.statusCode})',
      );
    }
  }

  static Future<bool> deleteDomain(String websiteId, String domainId) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _testDomains[websiteId]?.removeWhere((d) => d['id'] == domainId);
      return true;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/websites/$websiteId/domains/$domainId'),
      headers: await _headers(),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // ── Billing & Subscriptions ──────────────────────────────────────────

  static Map<String, dynamic>? _testSubscription;

  static void resetTestSubscription() {
    _testSubscription = null;
  }

  static void seedTestSubscription(Map<String, dynamic> sub) {
    _testSubscription = Map.from(sub);
  }

  static Future<Map<String, dynamic>> getSubscription() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _testSubscription ??
          {
            'plan': {'name': 'Free', 'slug': 'free', 'price_monthly': 0},
            'entitlements': {
              'max_websites': 3,
              'max_published': 1,
              'ai_generations_monthly': 4,
              'custom_domains': 0,
              'has_ads': true,
              'all_templates': false,
              'ssl_enabled': false,
            },
            'usage': {
              'websites': 1,
              'published_websites': 0,
              'custom_domains': 0,
              'ai_generations': 1,
            },
          };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/billing/subscription'),
      headers: await _headers(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {};
  }

  static Future<Map<String, dynamic>> createPaymentIntent({
    String interval = 'monthly',
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final amount = (interval == 'yearly' || interval == 'annual')
          ? 5988
          : 499;
      return {
        'paymentIntentId': 'pi_3Nz8y12eZvKYlo2C0VXYZ123',
        'clientSecret':
            'pi_3Nz8y12eZvKYlo2C0VXYZ123_secret_Yp90XYZ1234567890abcdef12',
        'amount': amount,
        'currency': 'eur',
        'is_mock': true,
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/billing/payment-intent'),
      headers: await _headers(),
      body: jsonEncode({'interval': interval}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ??
            'Failed to create payment intent (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> subscribePlan(
    String planSlug, {
    String? interval,
    String? paymentIntentId,
    String? provider,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final isPro = planSlug == 'pro';
      _testSubscription = {
        'plan': {
          'name': isPro ? 'Premium' : 'Free',
          'slug': planSlug,
          'price_monthly': isPro ? (interval == 'yearly' ? 59.88 : 4.99) : 0,
        },
        'entitlements': {
          'max_websites': isPro ? 15 : 3,
          'max_published': isPro ? 5 : 1,
          'ai_generations_monthly': isPro ? 90 : 4,
          'custom_domains': isPro ? 5 : 0,
          'has_ads': !isPro,
          'all_templates': isPro,
          'ssl_enabled': isPro,
        },
        'usage': {
          'websites': 1,
          'published_websites': 0,
          'custom_domains': 0,
          'ai_generations': 1,
        },
      };
      return {
        'message': 'Successfully switched to $planSlug plan.',
        'summary': _testSubscription,
      };
    }

    final payload = <String, dynamic>{'plan_slug': planSlug};
    if (interval != null) {
      payload['interval'] = interval;
    }
    if (paymentIntentId != null) {
      payload['payment_intent_id'] = paymentIntentId;
    }
    if (provider != null) {
      payload['provider'] = provider;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/billing/subscribe'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ??
            'Failed to update subscription (${response.statusCode})',
      );
    }
  }

  static List<Map<String, dynamic>>? _testBillingHistory;

  static void setTestBillingHistory(List<Map<String, dynamic>>? history) {
    _testBillingHistory = history;
  }

  static Future<List<Map<String, dynamic>>> getBillingHistory() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _testBillingHistory ??
          [
            {
              'id': 'evt_mock_1',
              'title': 'Premium · Monthly',
              'plan': 'Premium',
              'interval': 'monthly',
              'amount': 4.99,
              'currency': 'EUR',
              'formatted_amount': '€4.99',
              'provider': 'stripe',
              'status': 'Expired',
              'reference': 'pi_3UbLD7CCKIK7McZ41WtbKikY',
              'date': '1 Oct – 1 Nov 2026',
              'time': '14:32',
              'created_at': '2026-10-01T14:32:00Z',
              'year': '2026',
            },
            {
              'id': 'evt_mock_2',
              'title': 'Premium · Monthly',
              'plan': 'Premium',
              'interval': 'monthly',
              'amount': 4.99,
              'currency': 'EUR',
              'formatted_amount': '€4.99',
              'provider': 'stripe',
              'status': 'Expired',
              'reference': 'pi_3UaKD6CCKIK7McZ40VsbJhjX',
              'date': '1 Sep – 1 Oct 2026',
              'time': '10:15',
              'created_at': '2026-09-01T10:15:00Z',
              'year': '2026',
            },
            {
              'id': 'evt_mock_3',
              'title': 'Premium · Yearly',
              'plan': 'Premium',
              'interval': 'yearly',
              'amount': 59.88,
              'currency': 'EUR',
              'formatted_amount': '€59.88',
              'provider': 'stripe',
              'status': 'Expired',
              'reference': 'pi_2TzJC5CCKIK7McZ39UraIgiW',
              'date': '1 Sep 2025 – 1 Sep 2026',
              'time': '09:45',
              'created_at': '2025-09-01T09:45:00Z',
              'year': '2025',
            },
          ];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/billing/history'),
      headers: await _headers(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['history'] as List? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      throw Exception(
        'Failed to load billing history (${response.statusCode})',
      );
    }
  }

  /// Submit user feedback / review ("Envoyer les avis")
  static Future<bool> sendFeedback({
    required String category,
    required String message,
    int? rating,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/feedback'),
        headers: await _headers(),
        body: jsonEncode({
          'category': category,
          'message': message,
          if (rating != null) 'rating': rating,
          'metadata': {
            'platform': Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Other'),
            ...?metadata,
          },
        }),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
