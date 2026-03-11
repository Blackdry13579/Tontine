class NotificationModel {
  final String id;
  final String titre;
  final String message;
  final String type;
  final bool lu;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    this.lu = false,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      titre: json['titre'] ?? '',
      message: json['description'] ?? json['message'] ?? '',
      type: json['type'] ?? 'info',
      lu: json['lu'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }
}
