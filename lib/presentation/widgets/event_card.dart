import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_constants.dart';
import '../../data/models/event_model.dart';
import '../../data/services/event_service.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final bool showBookmarkButton;
  final Function(bool)? onBookmarkChanged;
  final String? status;
  final bool showStatus;

  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
    this.showBookmarkButton = true,
    this.onBookmarkChanged,
    this.status,
    this.showStatus = true,
  }) : super(key: key);

  Future<void> _toggleBookmark(BuildContext context) async {
    try {
      final eventService = EventService();
      if (event.isBookmarked) {
        await eventService.removeBookmark(event.id);
      } else {
        await eventService.addBookmark(event.id);
      }
      if (onBookmarkChanged != null) {
        onBookmarkChanged!(!event.isBookmarked);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${event.isBookmarked ? 'remove' : 'add'} bookmark: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    event.posterImage ?? AppConstants.placeholderImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.primaryContainer,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (event.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          AppConstants.chipBorderRadius,
                        ),
                      ),
                      child: Text(
                        'Featured',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (showStatus && status != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(status!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Event details
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat('E, MMM d, y').format(event.startDate),
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.locationName,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(
                            AppConstants.chipBorderRadius,
                          ),
                        ),
                        child: Text(
                          event.categoryName,
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        event.isFree
                            ? 'Free'
                            : '\$${event.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          color:
                              event.isFree ? Colors.green : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return Colors.green;
      case 'attended':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending_payment':
        return Colors.orange;
      case 'not_registered':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return 'Registered';
      case 'attended':
        return 'Attended';
      case 'cancelled':
        return 'Cancelled';
      case 'pending_payment':
        return 'Pending Payment';
      case 'not_registered':
        return 'Not Registered';
      default:
        return status;
    }
  }
}
