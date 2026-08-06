import 'package:va_bookats/models/support_ticket.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/ticket-chat', arguments: ticket.id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.navOutline.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.ticketNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.lastMessage,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBadge(ticket.categoryLabel, AppColors.secondary),
                const SizedBox(width: 8),
                _buildBadge(ticket.priorityLabel, _getPriorityColor()),
                const Spacer(),
                if (ticket.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      ticket.unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        ticket.statusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (ticket.status) {
      case 'open':
        return Colors.blue;
      case 'assigned':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return AppColors.grey;
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor() {
    switch (ticket.priority) {
      case 'urgent':
        return AppColors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      default:
        return AppColors.grey;
    }
  }

  String _formatTime() {
    if (ticket.lastMessageAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(ticket.lastMessageAt!);

    if (diff.inMinutes < 1) return 'ticket.time.justNow'.trns();
    if (diff.inHours < 1) {
      return 'ticket.time.minutesAgo'.trnsFormat({'count': diff.inMinutes});
    }
    if (diff.inDays < 1) {
      return 'ticket.time.hoursAgo'.trnsFormat({'count': diff.inHours});
    }
    if (diff.inDays < 7) {
      return 'ticket.time.daysAgo'.trnsFormat({'count': diff.inDays});
    }

    return DateFormat('MMM d').format(ticket.lastMessageAt!);
  }
}
