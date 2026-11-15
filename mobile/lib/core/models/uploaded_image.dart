class UploadedImage {
  final String id;
  final String filename;
  final String dimensions;
  final String url;
  final String alt;
  final String? siteId;
  final String? siteName;
  final int? fileSizeKb;
  final String? mimeType;
  final DateTime? createdAt;

  const UploadedImage({
    required this.id,
    required this.filename,
    required this.dimensions,
    required this.url,
    this.alt = '',
    this.siteId,
    this.siteName,
    this.fileSizeKb,
    this.mimeType,
    this.createdAt,
  });

  String get formattedSize {
    if (fileSizeKb != null && fileSizeKb! > 0) {
      if (fileSizeKb! >= 1024) {
        return '${(fileSizeKb! / 1024).toStringAsFixed(1)} MB';
      }
      return '$fileSizeKb KB';
    }
    return '1.2 MB';
  }

  String get fileExtension {
    if (filename.contains('.')) {
      return filename.split('.').last.toUpperCase();
    }
    return 'JPG';
  }

  bool get isDataUrl => url.startsWith('data:');

  UploadedImage copyWith({
    String? id,
    String? filename,
    String? dimensions,
    String? url,
    String? alt,
    String? siteId,
    String? siteName,
    int? fileSizeKb,
    String? mimeType,
    DateTime? createdAt,
  }) {
    return UploadedImage(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      dimensions: dimensions ?? this.dimensions,
      url: url ?? this.url,
      alt: alt ?? this.alt,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      fileSizeKb: fileSizeKb ?? this.fileSizeKb,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'dimensions': dimensions,
    'url': url,
    'alt': alt,
    'site_id': siteId,
    'site_name': siteName,
    'file_size_kb': fileSizeKb,
    'mime_type': mimeType,
    'created_at': createdAt?.toIso8601String(),
  };

  factory UploadedImage.fromJson(Map<String, dynamic> json) => UploadedImage(
    id: json['id'] as String,
    filename: json['filename'] as String,
    dimensions: json['dimensions'] as String? ?? 'Original ratio',
    url: json['url'] as String,
    alt: json['alt'] as String? ?? '',
    siteId: json['site_id'] as String?,
    siteName: json['site_name'] as String?,
    fileSizeKb: json['file_size_kb'] as int?,
    mimeType: json['mime_type'] as String?,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
  );
}

