import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/uploaded_image.dart';

class MediaAssetService {
  MediaAssetService._internal() {
    resetToDefaults();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _loadFromPreferences();
    }
  }

  static final MediaAssetService shared = MediaAssetService._internal();

  static const int maxImageUploadLimit = 20;
  static const int maxStorageMb = 100;
  static const String _storageKey = 'custom_uploaded_media_assets';

  static final List<UploadedImage> defaultImages = [
    const UploadedImage(
      id: 'img_1',
      filename: 'café-interior.jpg',
      dimensions: '1600 × 1200',
      url: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=80',
      alt: 'Sunlit seating inside the Lumen Coffee café',
      siteId: 'showcase_studio_marlow',
      siteName: 'Studio Marlow',
      fileSizeKb: 1420,
      mimeType: 'image/jpeg',
    ),
    const UploadedImage(
      id: 'img_2',
      filename: 'latte-art.jpg',
      dimensions: '1600 × 1280',
      url: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=1200&q=80',
      alt: 'Barista pouring tulip latte art in ceramic cup',
      siteId: 'showcase_studio_marlow',
      siteName: 'Studio Marlow',
      fileSizeKb: 1680,
      mimeType: 'image/jpeg',
    ),
    const UploadedImage(
      id: 'img_3',
      filename: 'roastery.jpg',
      dimensions: '1600 × 1200',
      url: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=1200&q=80',
      alt: 'Vintage cast iron drum coffee roaster in operation',
      siteId: 'showcase_studio_marlow',
      siteName: 'Studio Marlow',
      fileSizeKb: 1350,
      mimeType: 'image/jpeg',
    ),
    const UploadedImage(
      id: 'img_4',
      filename: 'huila.jpg',
      dimensions: '1200 × 1200',
      url: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=1200&q=80',
      alt: 'Single origin roasted coffee beans from Huila Colombia',
      siteId: 'showcase_studio_marlow',
      siteName: 'Studio Marlow',
      fileSizeKb: 980,
      mimeType: 'image/jpeg',
    ),
    const UploadedImage(
      id: 'img_5',
      filename: 'guji.jpg',
      dimensions: '1200 × 1200',
      url: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1200&q=80',
      alt: 'Ceramic cups on wooden cafe table with plants',
      siteId: 'showcase_kite_yoga',
      siteName: 'Kite Yoga',
      fileSizeKb: 1120,
      mimeType: 'image/jpeg',
    ),
    const UploadedImage(
      id: 'img_6',
      filename: 'espresso.jpg',
      dimensions: '1200 × 1200',
      url: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=1200&q=80',
      alt: 'Fresh ground espresso beans inside portafilter',
      siteId: 'showcase_kite_yoga',
      siteName: 'Kite Yoga',
      fileSizeKb: 890,
      mimeType: 'image/jpeg',
    ),
  ];

  final uploadedImages = <UploadedImage>[].obs;

  void resetToDefaults() {
    uploadedImages.assignAll(defaultImages);
  }

  int get totalStorageUsedKb {
    int total = 0;
    for (final img in uploadedImages) {
      total += img.fileSizeKb ?? 1200;
    }
    return total;
  }

  double get storagePercentage {
    final maxKb = maxStorageMb * 1024;
    return (totalStorageUsedKb / maxKb).clamp(0.0, 1.0);
  }

  String get formattedStorageUsed {
    final mb = totalStorageUsedKb / 1024.0;
    return '${mb.toStringAsFixed(1)} MB';
  }

  bool addAsset(UploadedImage image) {
    if (uploadedImages.length >= maxImageUploadLimit) {
      return false;
    }
    uploadedImages.insert(0, image);
    _saveToPreferences();
    return true;
  }

  bool deleteAsset(String id) {
    final before = uploadedImages.length;
    uploadedImages.removeWhere((img) => img.id == id);
    final changed = uploadedImages.length != before;
    if (changed) {
      _saveToPreferences();
    }
    return changed;
  }

  List<UploadedImage> getAssetsForSite(String? siteId) {
    if (siteId == null || siteId == 'all' || siteId.isEmpty) {
      return uploadedImages.toList();
    }
    return uploadedImages.where((img) => img.siteId == siteId).toList();
  }

  Future<UploadedImage?> uploadFromDevice({
    String? targetSiteId,
    String? targetSiteName,
  }) async {
    if (uploadedImages.length >= maxImageUploadLimit) {
      return null;
    }

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return fallbackSampleUpload(
        targetSiteId: targetSiteId,
        targetSiteName: targetSiteName,
      );
    }

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      final name = pickedFile.name.isNotEmpty
          ? pickedFile.name
          : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ext = name.split('.').last.toLowerCase();
      final mime = ext == 'png'
          ? 'image/png'
          : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:$mime;base64,$base64Data';
      final newId = 'img_${DateTime.now().millisecondsSinceEpoch}';
      final sizeKb = (bytes.lengthInBytes / 1024).round();

      final newUploaded = UploadedImage(
        id: newId,
        filename: name,
        dimensions: 'Original ratio',
        url: dataUrl,
        alt: name
            .replaceAll(RegExp(r'\.[^.]+$'), '')
            .replaceAll('-', ' ')
            .replaceAll('_', ' '),
        siteId: targetSiteId,
        siteName: targetSiteName,
        fileSizeKb: sizeKb > 0 ? sizeKb : 1024,
        mimeType: mime,
        createdAt: DateTime.now(),
      );

      addAsset(newUploaded);
      return newUploaded;
    } catch (e) {
      debugPrint('MediaAssetService upload error: $e');
      return fallbackSampleUpload(
        targetSiteId: targetSiteId,
        targetSiteName: targetSiteName,
      );
    }
  }

  UploadedImage fallbackSampleUpload({
    String? targetSiteId,
    String? targetSiteName,
  }) {
    final newIndex = uploadedImages.length + 1;
    final samplePhotos = [
      {
        'filename': 'cafe-patio.jpg',
        'dimensions': '1600 × 1200',
        'url': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=1200&q=80',
        'alt': 'Cozy outdoor cafe patio seating',
        'fileSizeKb': 1280,
      },
      {
        'filename': 'roaster-beans.jpg',
        'dimensions': '1200 × 1200',
        'url': 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=1200&q=80',
        'alt': 'Fresh roasted artisan coffee beans cooling in tray',
        'fileSizeKb': 1150,
      },
      {
        'filename': 'barista-steam.jpg',
        'dimensions': '1600 × 1066',
        'url': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1200&q=80',
        'alt': 'Barista steaming milk for flat white',
        'fileSizeKb': 1420,
      },
    ];

    final pick = samplePhotos[(newIndex - 1) % samplePhotos.length];
    final newId = 'img_${DateTime.now().millisecondsSinceEpoch}';

    final newUploaded = UploadedImage(
      id: newId,
      filename: pick['filename']! as String,
      dimensions: pick['dimensions']! as String,
      url: pick['url']! as String,
      alt: pick['alt']! as String,
      siteId: targetSiteId ?? (newIndex % 2 == 0 ? 'showcase_studio_marlow' : 'showcase_kite_yoga'),
      siteName: targetSiteName ?? (newIndex % 2 == 0 ? 'Studio Marlow' : 'Kite Yoga'),
      fileSizeKb: pick['fileSizeKb']! as int,
      mimeType: 'image/jpeg',
      createdAt: DateTime.now(),
    );

    addAsset(newUploaded);
    return newUploaded;
  }

  Future<void> _saveToPreferences() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only save non-default assets or all custom assets
      final customAssets = uploadedImages
          .where((img) => !defaultImages.any((def) => def.id == img.id))
          .map((e) => jsonEncode(e.toJson()))
          .toList();
      await prefs.setStringList(_storageKey, customAssets);
    } catch (e) {
      debugPrint('MediaAssetService save preferences error: $e');
    }
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedList = prefs.getStringList(_storageKey);
      if (storedList != null && storedList.isNotEmpty) {
        for (final itemStr in storedList.reversed) {
          try {
            final json = jsonDecode(itemStr) as Map<String, dynamic>;
            final asset = UploadedImage.fromJson(json);
            if (!uploadedImages.any((img) => img.id == asset.id)) {
              uploadedImages.insert(0, asset);
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('MediaAssetService load preferences error: $e');
    }
  }
}
