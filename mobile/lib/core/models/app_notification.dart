class AppNotification {
  final String id;
  final String? userId;
  final String type; // 'ai_modification', 'site_live', 'draft_reminder', 'admin_broadcast'
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? locale;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.locale,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  String? get websiteId => data['website_id']?.toString();
  String? get siteName => data['site_name']?.toString();
  String? get url => data['url']?.toString();
  String? get action => data['action']?.toString();
  String? get summary => data['summary']?.toString();

  AppNotification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? locale,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      locale: locale ?? this.locale,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      type: json['type']?.toString() ?? 'admin_broadcast',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : const {},
      locale: json['locale']?.toString(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'locale': locale,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
