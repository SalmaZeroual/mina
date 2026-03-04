class ServiceRequestModel {
  final String id;
  final String message;
  final String status; // pending | accepted | completed | cancelled
  final double? budget;
  final String? conversationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> service;
  final Map<String, dynamic> client;
  final Map<String, dynamic> provider;

  ServiceRequestModel({
    required this.id,
    required this.message,
    required this.status,
    this.budget,
    this.conversationId,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
    required this.client,
    required this.provider,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) =>
      ServiceRequestModel(
        id:             json['id']              as String? ?? '',
        message:        json['message']         as String? ?? '',
        status:         json['status']          as String? ?? 'pending',
        budget:         (json['budget']         as num?)?.toDouble(),
        conversationId: json['conversation_id'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
        service:  json['service']  as Map<String, dynamic>? ?? {},
        client:   json['client']   as Map<String, dynamic>? ?? {},
        provider: json['provider'] as Map<String, dynamic>? ?? {},
      );

  String get timeAgo {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 60)  return '${d.inMinutes}m ago';
    if (d.inHours   < 24)  return '${d.inHours}h ago';
    if (d.inDays    < 30)  return '${d.inDays}d ago';
    return '${(d.inDays / 30).round()}mo ago';
  }
}

class ServiceStatsModel {
  final int pending;
  final int accepted;
  final int completed;
  final int cancelled;
  final int total;

  ServiceStatsModel({
    this.pending = 0,
    this.accepted = 0,
    this.completed = 0,
    this.cancelled = 0,
    this.total = 0,
  });

  factory ServiceStatsModel.fromJson(Map<String, dynamic> json) =>
      ServiceStatsModel(
        pending:   json['pending']   as int? ?? 0,
        accepted:  json['accepted']  as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
        cancelled: json['cancelled'] as int? ?? 0,
        total:     json['total']     as int? ?? 0,
      );
}