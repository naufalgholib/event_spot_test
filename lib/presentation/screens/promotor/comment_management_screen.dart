import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_event_repository.dart';

class CommentManagementScreen extends StatefulWidget {
  final int eventId;

  const CommentManagementScreen({Key? key, required this.eventId})
      : super(key: key);

  @override
  State<CommentManagementScreen> createState() =>
      _CommentManagementScreenState();
}

class _CommentManagementScreenState extends State<CommentManagementScreen> {
  final MockEventRepository _repository = MockEventRepository();
  bool _isLoading = true;
  EventModel? _event;

  // Mock list of comments
  final List<Map<String, dynamic>> _comments = [
    {
      'id': 1,
      'userId': 123,
      'userName': 'Sarah Johnson',
      'userAvatar': 'https://randomuser.me/api/portraits/women/32.jpg',
      'content':
          'This looks like an amazing event! Will there be food vendors available?',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      'isApproved': true,
      'replies': [
        {
          'id': 101,
          'userId': 456,
          'userName': 'Event Organizer',
          'userAvatar': 'https://randomuser.me/api/portraits/men/8.jpg',
          'content':
              'Yes, we will have a variety of food vendors at the event!',
          'timestamp': DateTime.now().subtract(
            const Duration(days: 2, hours: 4),
          ),
          'isApproved': true,
        },
      ],
    },
    {
      'id': 2,
      'userId': 789,
      'userName': 'Michael Brown',
      'userAvatar': 'https://randomuser.me/api/portraits/men/45.jpg',
      'content': 'Is there parking available near the venue?',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      'isApproved': true,
      'replies': [],
    },
    {
      'id': 3,
      'userId': 101,
      'userName': 'Jennifer Garcia',
      'userAvatar': 'https://randomuser.me/api/portraits/women/56.jpg',
      'content': 'Do you offer student discounts for this event?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 20)),
      'isApproved': false,
      'replies': [],
    },
    {
      'id': 4,
      'userId': 112,
      'userName': 'Robert Wilson',
      'userAvatar': 'https://randomuser.me/api/portraits/men/26.jpg',
      'content':
          'Looking forward to this event! I attended last year and it was fantastic.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 15)),
      'isApproved': true,
      'replies': [],
    },
    {
      'id': 5,
      'userId': 134,
      'userName': 'Lisa Martinez',
      'userAvatar': 'https://randomuser.me/api/portraits/women/19.jpg',
      'content':
          'Will this event be accessible for people with mobility issues?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
      'isApproved': true,
      'replies': [],
    },
  ];

  // Filter options
  String _filterOption = 'All';
  final List<String> _filterOptions = [
    'All',
    'Approved',
    'Pending',
    'Most Recent',
  ];
  List<Map<String, dynamic>> _filteredComments = [];

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _applyFilter();
  }

  Future<void> _loadEventData() async {
    try {
      final event = await _repository.getEventById(widget.eventId);
      setState(() {
        _event = event;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load event data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _applyFilter() {
    List<Map<String, dynamic>> filtered = [];

    switch (_filterOption) {
      case 'Approved':
        filtered = _comments
            .where((comment) => comment['isApproved'] == true)
            .toList();
        break;
      case 'Pending':
        filtered = _comments
            .where((comment) => comment['isApproved'] == false)
            .toList();
        break;
      case 'Most Recent':
        filtered = List.from(_comments);
        filtered.sort((a, b) {
          return (b['timestamp'] as DateTime).compareTo(
            a['timestamp'] as DateTime,
          );
        });
        break;
      default: // 'All'
        filtered = List.from(_comments);
        break;
    }

    setState(() {
      _filteredComments = filtered;
    });
  }

  void _toggleApproval(int commentId) {
    final commentIndex = _comments.indexWhere(
      (comment) => comment['id'] == commentId,
    );
    if (commentIndex != -1) {
      setState(() {
        _comments[commentIndex]['isApproved'] =
            !_comments[commentIndex]['isApproved'];
        _applyFilter();
      });

      // Show confirmation
      final isApproved = _comments[commentIndex]['isApproved'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Comment ${isApproved ? 'approved' : 'unapproved'} successfully',
          ),
          backgroundColor: isApproved ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _deleteComment(int commentId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _comments.removeWhere(
                  (comment) => comment['id'] == commentId,
                );
                _applyFilter();
              });
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _replyToComment(int commentId) {
    // Find the comment to reply to
    final comment = _comments.firstWhere(
      (c) => c['id'] == commentId,
      orElse: () => {},
    );
    if (comment.isEmpty) return;

    final TextEditingController replyController = TextEditingController();

    // Show dialog with reply form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original comment
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(comment['userAvatar']),
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['userName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        comment['content'],
                        style: TextStyle(color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Your Reply:'),
            const SizedBox(height: 8),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Type your reply here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.isNotEmpty) {
                Navigator.pop(context);

                // Add the reply
                final reply = {
                  'id': 1000 + _comments.length, // Mock ID generation
                  'userId': 456, // Mock user ID (organizer)
                  'userName': 'Event Organizer',
                  'userAvatar': 'https://randomuser.me/api/portraits/men/8.jpg',
                  'content': replyController.text,
                  'timestamp': DateTime.now(),
                  'isApproved': true,
                };

                setState(() {
                  final index = _comments.indexWhere(
                    (c) => c['id'] == commentId,
                  );
                  if (index != -1) {
                    List<Map<String, dynamic>> replies = List.from(
                      _comments[index]['replies'],
                    );
                    replies.add(reply);
                    _comments[index]['replies'] = replies;
                    _applyFilter();
                  }
                });

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reply posted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Post Reply'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_event != null ? 'Comments: ${_event!.title}' : 'Comments'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterSection(),
                Expanded(child: _buildCommentsList()),
              ],
            ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment stats
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    icon: Icons.comment,
                    value: _comments.length.toString(),
                    label: 'Total',
                  ),
                  _buildStatCard(
                    icon: Icons.check_circle,
                    value: _comments
                        .where((c) => c['isApproved'] == true)
                        .length
                        .toString(),
                    label: 'Approved',
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    icon: Icons.pending,
                    value: _comments
                        .where((c) => c['isApproved'] == false)
                        .length
                        .toString(),
                    label: 'Pending',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          // Filter dropdown
          Row(
            children: [
              const Text('Filter: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _filterOption,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _filterOption = newValue;
                    });
                    _applyFilter();
                  }
                },
                items: _filterOptions.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const Spacer(),
              // Toggle switch for show/hide replies
              const Text('Show Replies'),
              Switch(
                value: true, // Always true for now
                onChanged: (value) {
                  // In a real app, this would toggle showing replies
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    Color color = Colors.blue,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (_filteredComments.isEmpty) {
      return const Center(
        child: Text('No comments found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: _filteredComments.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final comment = _filteredComments[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommentCard(comment),
            // Replies
            if (comment['replies'] != null &&
                (comment['replies'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 8),
                child: Column(
                  children: [
                    for (var reply in comment['replies'])
                      _buildReplyCard(reply),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(comment['userAvatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['userName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTimeAgo(comment['timestamp']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Approval status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: comment['isApproved']
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    comment['isApproved'] ? 'Approved' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: comment['isApproved']
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(comment['content']),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Reply button
                TextButton.icon(
                  onPressed: () {
                    _replyToComment(comment['id']);
                  },
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Reply'),
                ),
                // Approve/Unapprove button
                IconButton(
                  onPressed: () {
                    _toggleApproval(comment['id']);
                  },
                  icon: Icon(
                    comment['isApproved']
                        ? Icons.unpublished
                        : Icons.check_circle,
                    color: comment['isApproved'] ? Colors.orange : Colors.green,
                  ),
                  tooltip: comment['isApproved'] ? 'Unapprove' : 'Approve',
                ),
                // Delete button
                IconButton(
                  onPressed: () {
                    _deleteComment(comment['id']);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(Map<String, dynamic> reply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(reply['userAvatar']),
                  radius: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply['userName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(reply['timestamp']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                // Label showing this is a reply from organizer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Organizer',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reply['content'], style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
