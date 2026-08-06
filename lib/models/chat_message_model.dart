import '../network/api/api_path.dart';

class ChatMessageSender {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? photo;

  ChatMessageSender({
    required this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.photo,
  });

  String get fullName {
    final combined = [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ')
        .trim();
    if (combined.isNotEmpty) return combined;
    return name?.trim() ?? 'User';
  }

  factory ChatMessageSender.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    return ChatMessageSender(
      id: idValue is num ? idValue.toInt() : 0,
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      name: () {
        final n = json['name'];
        if (n is String) return n;
        if (n == null) return null;
        return n.toString();
      }(),
      photo: () {
        final p = json['photo'];
        if (p == null) return null;
        final ps = p.toString();
        if (ps.startsWith('http')) return ps;
        if (ps.isEmpty) return null;
        return '${ApiPath.imageUrl}/$ps';
      }(),
    );
  }
}

class ChatMessageModel {
  final int id;
  final int chatId;
  final int senderId;
  final String type; // text | image | file | voice
  final String? message;
  final String? fileUrl;
  final String? fileName;
  final String? fileSize;
  final String? fileMime;
  final int? voiceDuration;
  final bool isRead;
  final String createdAt;
  final ChatMessageSender sender;

  // Local-only: tracks optimistic/pending state
  final bool isPending;
  final String? localFilePath;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    this.message,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileMime,
    this.voiceDuration,
    this.isRead = false,
    required this.createdAt,
    required this.sender,
    this.isPending = false,
    this.localFilePath,
  });

  bool get isImage =>
      type == 'image' ||
      (fileMime != null && fileMime!.startsWith('image/'));

  bool get isVoice => type == 'voice';
  bool get isFile => type == 'file' && !isImage;
  bool get isText => type == 'text';

  static String? _resolveMediaUrl(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    if (s.isEmpty) return null;
    if (s.startsWith('http')) return s;
    return '${ApiPath.imageUrl}/$s';
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: () {
        final val = json['id'];
        return val is num ? val.toInt() : 0;
      }(),
      chatId: () {
        final val = json['conversation_id'] ?? json['chat_id'];
        return val is num ? val.toInt() : 0;
      }(),
      senderId: () {
        final val = json['sender_id'];
        return val is num ? val.toInt() : 0;
      }(),
      type: () {
        final t = json['message_type'] ?? json['type'];
        if (t is String) return t;
        if (t == null) return 'text';
        return t.toString();
      }(),
      message: () {
        final m = json['message_text'] ?? json['message'];
        if (m is String) return m;
        if (m == null) return null;
        if (m is Map || m is List) return null;
        return m.toString();
      }(),
      fileUrl: _resolveMediaUrl(json['media_path'] ?? json['file_url']),
      fileName: () {
        final n = json['media_name'] ?? json['file_name'];
        if (n is String) return n;
        if (n == null) return null;
        if (n is Map || n is List) return null;
        return n.toString();
      }(),
      fileSize: () {
        final s = json['media_size'] ?? json['file_size'];
        if (s is String) return s;
        if (s == null) return null;
        if (s is num) return s.toString();
        if (s is Map || s is List) return null;
        return s.toString();
      }(),
      fileMime: () {
        final m = json['media_mime'] ?? json['file_mime'];
        if (m is String) return m;
        if (m == null) return null;
        if (m is Map || m is List) return null;
        return m.toString();
      }(),
      voiceDuration: () {
        final d = json['voice_duration'];
        if (d is num) return d.toInt();
        if (d is String) return int.tryParse(d);
        return null;
      }(),
      isRead: () {
        final r = json['is_read'];
        return r == true;
      }(),
      createdAt: () {
        final c = json['created_at'];
        if (c is String) return c;
        if (c == null) return DateTime.now().toIso8601String();
        return c.toString();
      }(),
      sender: () {
        final s = json['sender'];
        if (s is Map<String, dynamic>) {
          return ChatMessageSender.fromJson(s);
        }
        return ChatMessageSender(id: 0);
      }(),
    );
  }

  ChatMessageModel copyWith({bool? isRead, bool? isPending}) {
    return ChatMessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      type: type,
      message: message,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      fileMime: fileMime,
      voiceDuration: voiceDuration,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      sender: sender,
      isPending: isPending ?? this.isPending,
      localFilePath: localFilePath,
    );
  }
}
