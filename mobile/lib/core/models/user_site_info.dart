class UserSiteInfo {
  final String id;
  final String name;
  final String? domain;
  final String? subdomain;
  final String status; // 'live' or 'draft'
  final String category;
  final String? imageUrl;
  final int assetCount;
  final String timeAgo;
  final bool isLive;
  final Map<String, dynamic>? document;

  const UserSiteInfo({
    required this.id,
    required this.name,
    this.domain,
    this.subdomain,
    required this.status,
    required this.category,
    this.imageUrl,
    this.assetCount = 0,
    required this.timeAgo,
    this.isLive = false,
    this.document,
  });

  UserSiteInfo copyWith({
    String? id,
    String? name,
    String? domain,
    String? subdomain,
    String? status,
    String? category,
    String? imageUrl,
    int? assetCount,
    String? timeAgo,
    bool? isLive,
    Map<String, dynamic>? document,
  }) {
    return UserSiteInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      subdomain: subdomain ?? this.subdomain,
      status: status ?? this.status,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      assetCount: assetCount ?? this.assetCount,
      timeAgo: timeAgo ?? this.timeAgo,
      isLive: isLive ?? this.isLive,
      document: document ?? this.document,
    );
  }
}

