import 'package:flutter/material.dart';
import '../../../core/config/app_router.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'New Event Near You',
      message: 'Music Festival 2023 is happening next week in your city!',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.event,
      isRead: false,
    ),
    NotificationItem(
      title: 'Registration Confirmed',
      message: 'Your registration for Tech Conference 2023 has been confirmed.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.registration,
      isRead: true,
    ),
    NotificationItem(
      title: 'Price Drop Alert',
      message: 'Art Exhibition tickets now available at a 20% discount!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.promo,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read logic here
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
            },
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyStateWidget(
              message: 'No notifications yet',
              icon: Icons.notifications_none,
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final difference = now.difference(notification.time);

    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} hr ago';
    } else {
      timeAgo = '${difference.inDays} days ago';
    }

    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.event:
        iconData = Icons.event;
        iconColor = Colors.blue;
        break;
      case NotificationType.registration:
        iconData = Icons.confirmation_number;
        iconColor = Colors.green;
        break;
      case NotificationType.promo:
        iconData = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.purple;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            timeAgo,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: notification.isRead
          ? null
          : theme.colorScheme.primaryContainer.withOpacity(0.1),
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
        // Navigate based on notification type
      },
    );
  }
}

enum NotificationType { event, registration, promo, system }

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}
