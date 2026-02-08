class ServiceRequest {
  final String id;
  final String customerId;
  final String? professionalId;
  final String categoryId;
  final String title;
  final String description;
  final String location;
  final String status;
  final DateTime? scheduledDate;
  final double? price;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceRequest({
    required this.id,
    required this.customerId,
    this.professionalId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.location,
    this.status = 'pending',
    this.scheduledDate,
    this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      professionalId: json['professional_id'] as String?,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      status: json['status'] as String? ?? 'pending',
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'professional_id': professionalId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'location': location,
      'status': status,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'price': price,
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
