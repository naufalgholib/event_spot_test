import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/event_model.dart';
import '../../data/models/registration_model.dart';
import '../../data/repositories/mock_registration_repository.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../widgets/common_widgets.dart';

class PaymentScreen extends StatefulWidget {
  final EventModel event;
  final RegistrationModel registration;

  const PaymentScreen({
    super.key,
    required this.event,
    required this.registration,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final MockRegistrationRepository _registrationRepository =
      MockRegistrationRepository();
  final MockUserRepository _userRepository = MockUserRepository();

  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  String? _error;

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_validateForm()) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Generate a mock payment ID
      final paymentId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';

      // Update registration with payment details
      await _registrationRepository.updatePaymentStatus(
        widget.registration.id,
        paymentStatus: 'completed',
        paymentMethod: _selectedPaymentMethod,
        paymentId: paymentId,
      );

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Payment Successful'),
                content: const Text(
                  'Your payment has been processed successfully. You will receive a confirmation email shortly.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Return to event detail
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to process payment. Please try again.';
          _isProcessing = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty ||
        _nameController.text.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields';
      });
      return false;
    }

    // Add more validation as needed
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _summaryRow('Event', widget.event.title),
                    _summaryRow(
                      'Date',
                      DateFormat('E, MMM d, y').format(widget.event.startDate),
                    ),
                    _summaryRow(
                      'Amount',
                      NumberFormat.currency(
                        symbol: '\$',
                      ).format(widget.event.price),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method Selection
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'card',
                  label: Text('Credit Card'),
                  icon: Icon(Icons.credit_card),
                ),
                ButtonSegment<String>(
                  value: 'paypal',
                  label: Text('PayPal'),
                  icon: Icon(Icons.account_balance_wallet),
                ),
              ],
              selected: {_selectedPaymentMethod},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedPaymentMethod = selection.first;
                });
              },
            ),

            const SizedBox(height: 24),

            // Payment Form
            if (_selectedPaymentMethod == 'card') ...[
              const Text(
                'Card Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name on Card',
                  hintText: 'John Doe',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ] else ...[
              // PayPal form would go here
              const Center(child: Text('PayPal integration coming soon')),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],

            const SizedBox(height: 24),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text:
                    _isProcessing
                        ? 'Processing...'
                        : 'Pay ${NumberFormat.currency(symbol: '\$').format(widget.event.price)}',
                onPressed:
                    _isProcessing
                        ? (() {})
                        : (() {
                          _processPayment();
                        }),
              ),
            ),

            const SizedBox(height: 16),

            // Security Note
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Secure Payment',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
