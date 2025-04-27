import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_event_repository.dart';

class AttendeeManagementScreen extends StatefulWidget {
  final int eventId;

  const AttendeeManagementScreen({Key? key, required this.eventId})
      : super(key: key);

  @override
  State<AttendeeManagementScreen> createState() =>
      _AttendeeManagementScreenState();
}

class _AttendeeManagementScreenState extends State<AttendeeManagementScreen> {
  final MockEventRepository _repository = MockEventRepository();
  bool _isLoading = true;
  EventModel? _event;

  // Mock list of attendees
  final List<Map<String, dynamic>> _attendees = [
    {
      'id': 1,
      'name': 'John Smith',
      'email': 'john.smith@example.com',
      'status': 'registered',
      'ticketCode': 'TIX12345',
      'registrationDate': DateTime.now().subtract(const Duration(days: 5)),
      'checkInTime': null,
    },
    {
      'id': 2,
      'name': 'Sarah Johnson',
      'email': 'sarah.j@example.com',
      'status': 'attended',
      'ticketCode': 'TIX12346',
      'registrationDate': DateTime.now().subtract(const Duration(days: 6)),
      'checkInTime': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 3,
      'name': 'Michael Wong',
      'email': 'michael.wong@example.com',
      'status': 'registered',
      'ticketCode': 'TIX12347',
      'registrationDate': DateTime.now().subtract(const Duration(days: 3)),
      'checkInTime': null,
    },
    {
      'id': 4,
      'name': 'Emily Davis',
      'email': 'emily.d@example.com',
      'status': 'cancelled',
      'ticketCode': 'TIX12348',
      'registrationDate': DateTime.now().subtract(const Duration(days: 10)),
      'checkInTime': null,
    },
    {
      'id': 5,
      'name': 'David Wilson',
      'email': 'david.w@example.com',
      'status': 'attended',
      'ticketCode': 'TIX12349',
      'registrationDate': DateTime.now().subtract(const Duration(days: 7)),
      'checkInTime': DateTime.now().subtract(const Duration(hours: 3)),
    },
  ];

  // Filter and search
  String _searchQuery = '';
  String _statusFilter = 'All';
  List<Map<String, dynamic>> _filteredAttendees = [];
  final List<String> _statusOptions = [
    'All',
    'Registered',
    'Attended',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _filteredAttendees = List.from(_attendees);
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

  void _filterAttendees() {
    List<Map<String, dynamic>> filtered = List.from(_attendees);

    // Apply status filter
    if (_statusFilter != 'All') {
      filtered = filtered.where((attendee) {
        return attendee['status'].toString().toLowerCase() ==
            _statusFilter.toLowerCase();
      }).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((attendee) {
        return attendee['name'].toString().toLowerCase().contains(query) ||
            attendee['email'].toString().toLowerCase().contains(query) ||
            attendee['ticketCode'].toString().toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredAttendees = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterAttendees();
  }

  void _exportAttendeeList() {
    // In a real app, this would generate and download a CSV or Excel file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendee list exported successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendMessageToAttendees() {
    // Show dialog to compose message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message to Attendees'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send a notification or email to all event attendees.',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Message Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Message Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message sent to attendees'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _checkInAttendee(int attendeeId) {
    // In a real app, this would update the database
    setState(() {
      final index = _attendees.indexWhere((a) => a['id'] == attendeeId);
      if (index != -1) {
        _attendees[index]['status'] = 'attended';
        _attendees[index]['checkInTime'] = DateTime.now();
        _filterAttendees();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendee checked in successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _event != null ? 'Attendees: ${_event!.title}' : 'Attendees',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Attendee List',
            onPressed: _exportAttendeeList,
          ),
          IconButton(
            icon: const Icon(Icons.message),
            tooltip: 'Message Attendees',
            onPressed: _sendMessageToAttendees,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltersSection(),
                Expanded(child: _buildAttendeeList()),
              ],
            ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendee stats
          _event != null
              ? Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          label: 'Total',
                          value: _attendees.length.toString(),
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          label: 'Registered',
                          value: _attendees
                              .where((a) => a['status'] == 'registered')
                              .length
                              .toString(),
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          label: 'Attended',
                          value: _attendees
                              .where((a) => a['status'] == 'attended')
                              .length
                              .toString(),
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          label: 'Cancelled',
                          value: _attendees
                              .where((a) => a['status'] == 'cancelled')
                              .length
                              .toString(),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),

          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, email or ticket code...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 8),

          // Status filter
          Row(
            children: [
              const Text('Status: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _statusFilter,
                underline: Container(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _statusFilter = newValue;
                    });
                    _filterAttendees();
                  }
                },
                items: _statusOptions.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }

  Widget _buildAttendeeList() {
    if (_filteredAttendees.isEmpty) {
      return const Center(
        child: Text('No attendees found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: _filteredAttendees.length,
      itemBuilder: (context, index) {
        final attendee = _filteredAttendees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(attendee['status']),
              child: Text(
                attendee['name'].substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(attendee['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attendee['email']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          attendee['status'],
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _capitalizeFirstLetter(attendee['status']),
                        style: TextStyle(
                          color: _getStatusColor(attendee['status']),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.confirmation_number,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attendee['ticketCode'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: attendee['status'] == 'registered'
                ? IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Check In',
                    onPressed: () {
                      _checkInAttendee(attendee['id']);
                    },
                  )
                : attendee['status'] == 'attended'
                    ? Tooltip(
                        message:
                            'Checked in at ${_formatTime(attendee['checkInTime'])}',
                        child: Icon(Icons.check_circle, color: Colors.green),
                      )
                    : null,
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return Colors.orange;
      case 'attended':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeFirstLetter(String text) {
    return text.isEmpty ? '' : text[0].toUpperCase() + text.substring(1);
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
