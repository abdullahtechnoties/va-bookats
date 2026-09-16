// lib/models/media_model.dart

/// A single row from `GET /media`.
class MediaModel {
  final int id;
  final String fileName;
  final String mimeType;
  final int size;
  final int thumbnailSize;
  final int? width;
  final int? height;
  final String url;
  final String thumbnailUrl;
  final String? createdAt;
  final String? updatedAt;

  const MediaModel({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.thumbnailSize,
    this.width,
    this.height,
    required this.url,
    required this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: _parseInt(json['id']) ?? 0,
      fileName: json['file_name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      size: _parseInt(json['size']) ?? 0,
      thumbnailSize: _parseInt(json['thumbnail_size']) ?? 0,
      width: _parseInt(json['width']),
      height: _parseInt(json['height']),
      url: json['url']?.toString() ?? '',
      thumbnailUrl: (json['thumbnail_url'] ?? json['url'])?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Best display url — thumbnail when available, else full url.
  String get displayUrl => thumbnailUrl.isNotEmpty ? thumbnailUrl : url;

  String get sizeLabel {
    if (size <= 0) return '—';
    if (size < 1024) return '$size B';
    final kb = size / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(2)} KB';
    return '${(kb / 1024).toStringAsFixed(2)} MB';
  }

  String get dimensionsLabel {
    if (width != null && height != null && width! > 0 && height! > 0) {
      return '$width x $height';
    }
    return '—';
  }

  String get uploadedLabel {
    if (createdAt == null || createdAt!.isEmpty) return '—';
    try {
      final dt = DateTime.parse(createdAt!);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final m = dt.month >= 1 && dt.month <= 12 ? months[dt.month] : '';
      return '$m ${dt.day}, ${dt.year}';
    } catch (_) {
      return createdAt!.length > 10 ? createdAt!.substring(0, 10) : createdAt!;
    }
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
