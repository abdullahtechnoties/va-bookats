import '../network/api/api_path.dart';

class ChatUserModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? photo;

  ChatUserModel({
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

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: () {
        final val = json['id'];
        return val is num ? val.toInt() : 0;
      }(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      name: json['name']?.toString(),
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

class ChatModel {
  final int id;
  final ChatUserModel otherUser;
  final String lastMessage;
  final String? lastMessageAt;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as int,
      otherUser: ChatUserModel.fromJson(
        json['other_user'] as Map<String, dynamic>,
      ),
      lastMessage: (json['last_message'] ?? '').toString(),
      lastMessageAt: json['last_message_at']?.toString(),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  ChatModel copyWith({int? unreadCount, String? lastMessage, String? lastMessageAt}) {
    return ChatModel(
      id: id,
      otherUser: otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
