class Project {
  final String id;
  final String name;
  final String? description;

  Project({
    required this.id,
    required this.name,
    this.description,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

class Website {
  final String id;
  final String projectId;
  final String name;
  final String slug;
  final String status;
  final String? subdomain;
  final int revisionNumber;
  final Map<String, dynamic>? document;

  Website({
    required this.id,
    required this.projectId,
    required this.name,
    required this.slug,
    required this.status,
    this.subdomain,
    required this.revisionNumber,
    this.document,
  });

  factory Website.fromJson(Map<String, dynamic> json) {
    return Website(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      status: json['status'] as String,
      subdomain: json['subdomain'] as String?,
      revisionNumber: json['revision_number'] as int? ?? 1,
      document: json['document'] as Map<String, dynamic>?,
    );
  }
}

