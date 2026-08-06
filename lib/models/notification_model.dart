import 'package:va_bookats/network/api/api_path.dart';

class NotificationModel {
  final int id;
  final int? senderId;
  final String? modelType;
  final int? modelId;
  final String status;
  final String message;
  final String? title;
  final String? route;
  final String? createdAt;
  final String? updatedAt;
  final String senderFirstName;
  final String? senderLastName;
  final String? senderPhotoPath;

  const NotificationModel({
    required this.id,
    this.senderId,
    this.modelType,
    this.modelId,
    required this.status,
    required this.message,
    this.title,
    this.route,
    this.createdAt,
    this.updatedAt,
    required this.senderFirstName,
    this.senderLastName,
    this.senderPhotoPath,
  });

  bool get isUnread => status.toLowerCase() == 'unread';

  String get senderFullName {
    final parts = [senderFirstName, senderLastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(' ')
        .trim();
    return parts.isNotEmpty ? parts : senderFirstName;
  }

  String? get senderFullPhotoUrl {
    if (senderPhotoPath == null || senderPhotoPath!.trim().isEmpty) return null;
    if (senderPhotoPath!.startsWith('http')) return senderPhotoPath;
    return '${ApiPath.imageUrl}/$senderPhotoPath';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? sender;
    final rawSender = json['sender'];
    if (rawSender is Map) {
      sender = Map<String, dynamic>.from(rawSender);
    }

    return NotificationModel(
      id: _parseInt(json['id']) ?? 0,
      senderId: _parseInt(json['sender_id']),
      modelType: json['model_type']?.toString(),
      modelId: _parseInt(json['model_id']),
      status: json['status']?.toString() ?? 'unread',
      message: json['message']?.toString() ?? '',
      title: json['title']?.toString(),
      route: json['route']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      senderFirstName: sender?['first_name']?.toString() ?? '',
      senderLastName: sender?['last_name']?.toString(),
      senderPhotoPath: sender?['photo_path']?.toString(),
    );
  }

  NotificationModel copyWith({
    int? id,
    int? senderId,
    String? modelType,
    int? modelId,
    String? status,
    String? message,
    String? title,
    String? route,
    String? createdAt,
    String? updatedAt,
    String? senderFirstName,
    String? senderLastName,
    String? senderPhotoPath,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      modelType: modelType ?? this.modelType,
      modelId: modelId ?? this.modelId,
      status: status ?? this.status,
      message: message ?? this.message,
      title: title ?? this.title,
      route: route ?? this.route,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderFirstName: senderFirstName ?? this.senderFirstName,
      senderLastName: senderLastName ?? this.senderLastName,
      senderPhotoPath: senderPhotoPath ?? this.senderPhotoPath,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
