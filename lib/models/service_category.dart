class ServiceCategory {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime createdAt;

  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.createdAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }
}
