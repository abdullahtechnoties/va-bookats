// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MessageBubble extends StatelessWidget {
//   final SupportMessage message;
//   final bool isMe;

//   const MessageBubble({
//     super.key,
//     required this.message,
//     required this.isMe,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (message.isSystem) {
//       return _buildSystemMessage();
//     }

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isMe) ...[
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
//               backgroundImage: message.sender.photo != null
//                   ? NetworkImage(message.sender.photo!)
//                   : null,
//               child: message.sender.photo == null
//                   ? Text(
//                       message.sender.name[0].toUpperCase(),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.secondary,
//                       ),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Column(
//               crossAxisAlignment:
//                   isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 if (!isMe)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8, bottom: 4),
//                     child: Text(
//                       message.sender.name,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.grey,
//                       ),
//                     ),
//                   ),
//                 _buildMessageContent(),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         _formatTime(),
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: AppColors.grey.withValues(alpha: 0.6),
//                         ),
//                       ),
//                       if (isMe) ...[
//                         const SizedBox(width: 4),
//                         Icon(
//                           message.isRead ? Icons.done_all : Icons.done,
//                           size: 14,
//                           color: message.isRead
//                               ? AppColors.secondary
//                               : AppColors.grey.withValues(alpha: 0.6),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // if (isMe) const SizedBox(width: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageContent() {
//     if (message.isText) {
//       return _buildTextBubble();
//     } else if (message.isImage) {
//       return _buildImageBubble();
//     } else if (message.isFile) {
//       return _buildFileBubble();
//     } else if (message.isVoice) {
//       return VoiceMessagePlayer(
//         message: message,
//         isMe: isMe,
//       );
//     }

//     return const SizedBox.shrink();
//   }

//   Widget _buildTextBubble() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: isMe
//             ? AppColors.secondary
//             : AppColors.primary.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.only(
//           topLeft: const Radius.circular(16),
//           topRight: const Radius.circular(16),
//           bottomLeft: Radius.circular(isMe ? 16 : 4),
//           bottomRight: Radius.circular(isMe ? 4 : 16),
//         ),
//       ),
//       child: Text(
//         message.message ?? '',
//         style: TextStyle(
//           fontSize: 14,
//           color: isMe ? AppColors.white : AppColors.black,
//           height: 1.4,
//         ),
//       ),
//     );
//   }

//   Widget _buildImageBubble() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: AppCachedImage(
//         imageUrl: message.fileUrl,
//         width: 250,
//         height: 250,
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   Widget _buildFileBubble() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isMe
//             ? AppColors.secondary
//             : AppColors.primary.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.insert_drive_file,
//             color: isMe ? AppColors.white : AppColors.secondary,
//             size: 24,
//           ),
//           const SizedBox(width: 12),
//           Flexible(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   message.fileName ?? 'File',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: isMe ? AppColors.white : AppColors.black,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (message.fileSize != null)
//                   Text(
//                     message.fileSize!,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: isMe
//                           ? AppColors.white.withValues(alpha: 0.7)
//                           : AppColors.grey.withValues(alpha: 0.7),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSystemMessage() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: AppColors.grey.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Text(
//           message.message ?? '',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 12,
//             color: AppColors.grey.withValues(alpha: 0.8),
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatTime() {
//     return DateFormat('h:mm a').format(message.createdAt.toLocal());
//   }
// }