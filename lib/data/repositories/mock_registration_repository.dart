import '../models/registration_model.dart';

class MockRegistrationRepository {
  final List<RegistrationModel> _registrations = [];
  int _lastId = 0;

  // Register for an event
  Future<RegistrationModel> registerForEvent(
    int eventId,
    int userId, {
    double? amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final registration = RegistrationModel(
      id: ++_lastId,
      eventId: eventId,
      userId: userId,
      status: 'pending',
      amount: amount,
      paymentStatus: amount != null ? 'pending' : null,
      createdAt: now,
      updatedAt: now,
    );

    _registrations.add(registration);
    return registration;
  }

  // Get registrations by user
  Future<List<RegistrationModel>> getRegistrationsByUser(int userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _registrations.where((reg) => reg.userId == userId).toList();
  }

  // Get registrations by event
  Future<List<RegistrationModel>> getRegistrationsByEvent(int eventId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _registrations.where((reg) => reg.eventId == eventId).toList();
  }

  // Update registration status
  Future<RegistrationModel> updateRegistrationStatus(
    int registrationId,
    String status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _registrations.indexWhere((reg) => reg.id == registrationId);
    if (index == -1) throw Exception('Registration not found');

    final registration = _registrations[index];
    final updatedRegistration = registration.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    _registrations[index] = updatedRegistration;
    return updatedRegistration;
  }

  // Update payment status
  Future<RegistrationModel> updatePaymentStatus(
    int registrationId, {
    required String paymentStatus,
    required String paymentMethod,
    required String paymentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _registrations.indexWhere((reg) => reg.id == registrationId);
    if (index == -1) throw Exception('Registration not found');

    final registration = _registrations[index];
    final updatedRegistration = registration.copyWith(
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      paymentId: paymentId,
      status: paymentStatus == 'completed' ? 'confirmed' : registration.status,
      ticketNumber:
          paymentStatus == 'completed'
              ? _generateTicketNumber(registration.eventId, registration.id)
              : registration.ticketNumber,
      updatedAt: DateTime.now(),
    );

    _registrations[index] = updatedRegistration;
    return updatedRegistration;
  }

  // Cancel registration
  Future<RegistrationModel> cancelRegistration(int registrationId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _registrations.indexWhere((reg) => reg.id == registrationId);
    if (index == -1) throw Exception('Registration not found');

    final registration = _registrations[index];
    final updatedRegistration = registration.copyWith(
      status: 'cancelled',
      updatedAt: DateTime.now(),
    );

    _registrations[index] = updatedRegistration;
    return updatedRegistration;
  }

  // Check if user is registered for event
  Future<bool> isUserRegistered(int eventId, int userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _registrations.any(
      (reg) =>
          reg.eventId == eventId &&
          reg.userId == userId &&
          reg.status != 'cancelled',
    );
  }

  // Get registration by ID
  Future<RegistrationModel?> getRegistrationById(int registrationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _registrations.firstWhere((reg) => reg.id == registrationId);
    } catch (e) {
      return null;
    }
  }

  // Generate ticket number
  String _generateTicketNumber(int eventId, int registrationId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TIX-${eventId.toString().padLeft(4, '0')}-${registrationId.toString().padLeft(6, '0')}-${timestamp % 1000}';
  }
}
