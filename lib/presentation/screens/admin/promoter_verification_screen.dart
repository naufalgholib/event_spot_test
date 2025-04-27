import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'package:event_spot/data/models/user_model.dart';

class PromoterVerificationScreen extends StatefulWidget {
  const PromoterVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PromoterVerificationScreen> createState() =>
      _PromoterVerificationScreenState();
}

class _PromoterVerificationScreenState
    extends State<PromoterVerificationScreen> {
  // Mock data for pending verification requests
  final List<Map<String, dynamic>> _verificationRequests = [
    {
      'id': 1,
      'user': UserModel(
        id: 10,
        name: 'David Wilson',
        email: 'david.wilson@example.com',
        phoneNumber: '+1122334455',
        userType: 'promotor',
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      'companyName': 'Wilson Events',
      'companyLogo': 'https://via.placeholder.com/150?text=WE',
      'website': 'https://wilsonevents.com',
      'description': 'We organize corporate events and conferences.',
      'submissionDate': DateTime.now().subtract(const Duration(days: 4)),
      'verificationDocument': 'business_license.pdf',
      'status': 'pending',
    },
    {
      'id': 2,
      'user': UserModel(
        id: 11,
        name: 'Emily Clark',
        email: 'emily.clark@example.com',
        phoneNumber: '+5566778899',
        userType: 'promotor',
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      'companyName': 'Clark Celebrations',
      'companyLogo': 'https://via.placeholder.com/150?text=CC',
      'website': 'https://clarkcelebrations.com',
      'description': 'We specialize in wedding and birthday celebrations.',
      'submissionDate': DateTime.now().subtract(const Duration(days: 2)),
      'verificationDocument': 'company_registration.pdf',
      'status': 'pending',
    },
    {
      'id': 3,
      'user': UserModel(
        id: 12,
        name: 'Michael Johnson',
        email: 'michael.johnson@example.com',
        phoneNumber: '+9988776655',
        userType: 'promotor',
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      'companyName': 'Johnson Music Festivals',
      'companyLogo': 'https://via.placeholder.com/150?text=JMF',
      'website': 'https://johnsonmusicfestivals.com',
      'description': 'Organizing music festivals and concerts since 2010.',
      'submissionDate': DateTime.now().subtract(const Duration(days: 6)),
      'verificationDocument': 'tax_certificate.pdf',
      'status': 'pending',
    },
  ];

  // Mock data for processed verification requests
  final List<Map<String, dynamic>> _processedRequests = [
    {
      'id': 4,
      'user': UserModel(
        id: 13,
        name: 'Sarah Adams',
        email: 'sarah.adams@example.com',
        phoneNumber: '+1212343456',
        userType: 'promotor',
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      'companyName': 'Adams Event Planning',
      'companyLogo': 'https://via.placeholder.com/150?text=AEP',
      'website': 'https://adamsevents.com',
      'description': 'Full-service event planning and coordination.',
      'submissionDate': DateTime.now().subtract(const Duration(days: 12)),
      'verificationDocument': 'business_license.pdf',
      'status': 'approved',
      'processedDate': DateTime.now().subtract(const Duration(days: 8)),
      'processedBy': 'Admin User',
    },
    {
      'id': 5,
      'user': UserModel(
        id: 14,
        name: 'Robert Taylor',
        email: 'robert.taylor@example.com',
        phoneNumber: '+3344556677',
        userType: 'promotor',
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      'companyName': 'Taylor Productions',
      'companyLogo': 'https://via.placeholder.com/150?text=TP',
      'website': 'https://taylorprod.com',
      'description': 'Television and live event production company.',
      'submissionDate': DateTime.now().subtract(const Duration(days: 18)),
      'verificationDocument': 'company_registration.pdf',
      'status': 'rejected',
      'processedDate': DateTime.now().subtract(const Duration(days: 10)),
      'processedBy': 'Admin User',
      'rejectionReason': 'Incomplete documentation provided.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Promoter Verification'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Requests'),
              Tab(text: 'Processed Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPendingRequestsTab(),
            _buildProcessedRequestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    if (_verificationRequests.isEmpty) {
      return const Center(
        child: Text('No pending verification requests'),
      );
    }

    return ListView.builder(
      itemCount: _verificationRequests.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final request = _verificationRequests[index];
        final user = request['user'] as UserModel;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: request['companyLogo'] != null
                          ? NetworkImage(request['companyLogo'])
                          : null,
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: request['companyLogo'] == null
                          ? Text(
                              request['companyName'][0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['companyName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Owner: ${user.name} (${user.email})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Submitted: ${_formatDate(request['submissionDate'])}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Company Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(request['description']),
                if (request['website'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.public, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        request['website'],
                        style: TextStyle(
                          color: Colors.blue[700],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attachment, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        // Show document preview in a dialog
                        _showDocumentPreviewDialog(request);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(request['verificationDocument']),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _showRejectDialog(request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _approveVerification(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessedRequestsTab() {
    if (_processedRequests.isEmpty) {
      return const Center(
        child: Text('No processed verification requests'),
      );
    }

    return ListView.builder(
      itemCount: _processedRequests.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final request = _processedRequests[index];
        final user = request['user'] as UserModel;
        final bool isApproved = request['status'] == 'approved';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: request['companyLogo'] != null
                          ? NetworkImage(request['companyLogo'])
                          : null,
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: request['companyLogo'] == null
                          ? Text(
                              request['companyName'][0],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                request['companyName'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isApproved ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isApproved ? 'Approved' : 'Rejected',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Owner: ${user.name} (${user.email})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Processed on: ${_formatDate(request['processedDate'])}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Company Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(request['description']),
                if (!isApproved && request['rejectionReason'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Rejection Reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request['rejectionReason'],
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _showRevertDecisionDialog(request),
                      child: const Text('Revert Decision'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDocumentPreviewDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Document: ${request['verificationDocument']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Document Preview'),
                    SizedBox(height: 8),
                    Text(
                      'In a real app, this would display the actual document',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> request) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'You are about to reject the verification request for ${request['companyName']}.'),
            const SizedBox(height: 16),
            const Text('Please provide a reason:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.of(context).pop();
                _rejectVerification(request, reasonController.text);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _approveVerification(Map<String, dynamic> request) {
    setState(() {
      // Update user verification status
      final user = request['user'] as UserModel;
      user.copyWith(isVerified: true);

      // Move request from pending to processed
      _verificationRequests.removeWhere((r) => r['id'] == request['id']);
      _processedRequests.add({
        ...request,
        'status': 'approved',
        'processedDate': DateTime.now(),
        'processedBy': 'Admin User',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['companyName']} has been approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectVerification(Map<String, dynamic> request, String reason) {
    setState(() {
      // Move request from pending to processed with rejection status
      _verificationRequests.removeWhere((r) => r['id'] == request['id']);
      _processedRequests.add({
        ...request,
        'status': 'rejected',
        'processedDate': DateTime.now(),
        'processedBy': 'Admin User',
        'rejectionReason': reason,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['companyName']} has been rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showRevertDecisionDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revert Decision'),
        content: Text(
          'Are you sure you want to revert the decision for ${request['companyName']}?\n\nThis will move the request back to the pending queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _revertDecision(request);
            },
            child: const Text('Revert'),
          ),
        ],
      ),
    );
  }

  void _revertDecision(Map<String, dynamic> request) {
    setState(() {
      // Move from processed back to pending
      _processedRequests.removeWhere((r) => r['id'] == request['id']);

      // Remove processed-specific fields
      final Map<String, dynamic> pendingRequest = Map.from(request);
      pendingRequest.remove('processedDate');
      pendingRequest.remove('processedBy');
      pendingRequest.remove('rejectionReason');
      pendingRequest['status'] = 'pending';

      _verificationRequests.add(pendingRequest);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Decision for ${request['companyName']} has been reverted'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
