class ServiceCategory {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color; // Added
  final DateTime? createdAt; // Made optional

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.createdAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
