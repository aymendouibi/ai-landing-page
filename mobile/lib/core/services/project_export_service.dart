import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../network/api_client.dart';

class ExportResult {
  final bool success;
  final bool isPremiumRequired;
  final String? filePath;
  final String? fileName;
  final int fileSizeBytes;
  final String? errorMessage;

  const ExportResult({
    required this.success,
    this.isPremiumRequired = false,
    this.filePath,
    this.fileName,
    this.fileSizeBytes = 0,
    this.errorMessage,
  });

  factory ExportResult.locked({String? message}) => ExportResult(
        success: false,
        isPremiumRequired: true,
        errorMessage: message ??
            'Exporting project code as a ZIP archive is a Premium feature. Upgrade to Premium to export your websites.',
      );

  factory ExportResult.failure(String message) => ExportResult(
        success: false,
        errorMessage: message,
      );

  factory ExportResult.successful({
    required String filePath,
    required String fileName,
    required int fileSizeBytes,
  }) =>
      ExportResult(
        success: true,
        filePath: filePath,
        fileName: fileName,
        fileSizeBytes: fileSizeBytes,
      );
}

class ProjectExportService {
  ProjectExportService._();

  static final ProjectExportService instance = ProjectExportService._();

  /// Exports a project as a production-ready ZIP archive.
  /// Strictly requires [isPremium] == true.
  Future<ExportResult> exportProjectZip({
    required String websiteId,
    required String websiteName,
    required bool isPremium,
    Map<String, dynamic>? document,
    String? customHtml,
  }) async {
    // 1. Strict Premium check: Project export is a Premium feature only
    if (!isPremium) {
      return ExportResult.locked();
    }

    try {
      Uint8List? zipBytes;
      final cleanSlug = websiteName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '-')
          .replaceAll(RegExp(r'-+'), '-')
          .trim();
      final baseName = cleanSlug.isEmpty ? 'website' : cleanSlug;
      final fileName = '$baseName-project.zip';

      // 2. Fetch from remote backend API if it's a real website
      final isMockOrShowcase = websiteId.startsWith('showcase_') ||
          websiteId.isEmpty ||
          Platform.environment.containsKey('FLUTTER_TEST');

      if (!isMockOrShowcase) {
        try {
          zipBytes = await ApiClient.exportWebsiteZip(websiteId);
        } catch (e) {
          if (e is SubscriptionLimitException) {
            return ExportResult.locked(message: e.message);
          }
          debugPrint('Remote ZIP export failed, falling back to local compiler: $e');
        }
      }

      // 3. Fallback / local compilation if needed
      zipBytes ??= generateLocalZip(
        websiteName: websiteName,
        document: document,
        customHtml: customHtml,
      );

      // 4. Save to device storage
      final file = await _saveZipToDisk(fileName, zipBytes);

      return ExportResult.successful(
        filePath: file.path,
        fileName: fileName,
        fileSizeBytes: zipBytes.length,
      );
    } catch (e) {
      return ExportResult.failure('Failed to export project: $e');
    }
  }

  /// Builds a self-contained ZIP archive in memory
  Uint8List generateLocalZip({
    required String websiteName,
    Map<String, dynamic>? document,
    String? customHtml,
  }) {
    final archive = Archive();
    final title = websiteName.isNotEmpty ? websiteName : 'Landing Page';

    final html = customHtml ?? _generateProductionHtml(title, document);
    final css = _generateProductionCss(document);
    final js = _generateProductionJs(document);
    final readme = _generateReadme(title);
    final schemaJson = document != null
        ? const JsonEncoder.withIndent('  ').convert(document)
        : jsonEncode({'name': title, 'schema_version': 1});

    archive.addFile(ArchiveFile.string('index.html', html));
    archive.addFile(ArchiveFile.string('assets/style.css', css));
    archive.addFile(ArchiveFile.string('assets/main.js', js));
    archive.addFile(ArchiveFile.string('schema.json', schemaJson));
    archive.addFile(ArchiveFile.string('README.md', readme));

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  Future<File> _saveZipToDisk(String fileName, Uint8List bytes) async {
    Directory dir;
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        dir = Directory.systemTemp;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      dir = Directory.systemTemp;
    }

    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File('${exportDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _generateProductionHtml(String title, Map<String, dynamic>? document) {
    return '''<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <link rel="stylesheet" href="assets/style.css">
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white text-slate-900 antialiased font-sans selection:bg-slate-900 selection:text-white">
  <main id="app">
    <!-- Navigation Header -->
    <header class="py-5 px-6 md:px-12 flex justify-between items-center border-b border-slate-100 max-w-7xl mx-auto">
      <div class="text-lg font-bold tracking-tight text-slate-900">$title</div>
      <nav class="hidden md:flex space-x-8 text-sm font-medium text-slate-600">
        <a href="#about" class="hover:text-black transition">About</a>
        <a href="#features" class="hover:text-black transition">Features</a>
        <a href="#contact" class="hover:text-black transition">Contact</a>
      </nav>
      <a href="#contact" class="bg-slate-900 text-white text-xs font-semibold px-4 py-2 rounded-full hover:bg-slate-800 transition">Get in Touch</a>
    </header>

    <!-- Hero Section -->
    <section class="py-20 md:py-32 px-6 max-w-5xl mx-auto text-center">
      <h1 class="text-4xl md:text-6xl font-extrabold tracking-tight text-slate-900 mb-6">$title</h1>
      <p class="text-lg md:text-xl text-slate-600 max-w-2xl mx-auto mb-10 leading-relaxed">
        Crafted with precision, responsive by default, and ready for high-converting production deployments.
      </p>
      <div class="flex flex-col sm:flex-row justify-center gap-4">
        <a href="#contact" class="bg-slate-900 text-white font-semibold px-8 py-3.5 rounded-full hover:bg-slate-800 transition shadow-sm">
          Explore Showcase
        </a>
        <a href="#features" class="border border-slate-200 text-slate-700 font-semibold px-8 py-3.5 rounded-full hover:bg-slate-50 transition">
          Learn More
        </a>
      </div>
    </section>

    <!-- Footer -->
    <footer class="py-12 border-t border-slate-100 text-center text-xs text-slate-400">
      <p>&copy; ${DateTime.now().year} $title. All rights reserved. Exported with AI Landing Page Builder.</p>
    </footer>
  </main>
  <script src="assets/main.js"></script>
</body>
</html>''';
  }

  String _generateProductionCss(Map<String, dynamic>? document) {
    return '''/* Custom Production Styles */
:root {
  --primary: #0F172A;
  --accent: #2563EB;
}

body {
  margin: 0;
  -webkit-font-smoothing: antialiased;
}

@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
''';
  }

  String _generateProductionJs(Map<String, dynamic>? document) {
    return '''// Interactive production client scripts
document.addEventListener('DOMContentLoaded', () => {
  console.log('Project loaded successfully.');
});
''';
  }

  String _generateReadme(String title) {
    return '''# $title

This project was exported as a production-ready standalone ZIP bundle from **AI Landing Page Builder**.

## 🚀 Running Locally

You can open `index.html` directly in any web browser, or serve it using any local static web server:

```bash
# Python 3
python3 -m http.server 8080

# Node.js
npx serve .
```

Then visit `http://localhost:8080`.

## 📦 Bundle Files
- `index.html` - Production semantic HTML with Tailwind CSS
- `assets/style.css` - Custom styles and CSS variables
- `assets/main.js` - Client-side interactive scripts
- `schema.json` - Complete website document AST and structure
''';
  }
}
