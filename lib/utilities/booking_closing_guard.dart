import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

Future<bool>? _closingCheckInFlight;
bool _protectedOperationInFlight = false;

Future<bool> _checkBookingClosingAllowed({
  required BookingRepository repository,
  required AuthService auth,
  required int? branchId,
}) async {
  if (auth.isOwner) return true;

  final response = branchId == null
      ? null
      : await repository.checkBookingClosing(branchId);
  final allowed = response?.isCompleted == true && response?.data == true;
  if (allowed) return true;

  await Get.dialog<void>(
    AlertDialog(
      backgroundColor: AppColors.white,
      title: Text('common.error'.trns()),
      content: Text(
        response?.message ??
            'Unable to verify the daily closing status. Please try again.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Close')),
      ],
    ),
    barrierDismissible: false,
  );
  return false;
}

Future<bool> ensureBookingClosingAllowed({
  required BookingRepository repository,
  required AuthService auth,
  required int? branchId,
}) {
  final activeCheck = _closingCheckInFlight;
  if (activeCheck != null) return activeCheck;

  final check = _checkBookingClosingAllowed(
    repository: repository,
    auth: auth,
    branchId: branchId,
  );
  _closingCheckInFlight = check;
  check.whenComplete(() {
    if (identical(_closingCheckInFlight, check)) {
      _closingCheckInFlight = null;
    }
  });
  return check;
}

Future<bool> runBookingClosingProtected({
  required BookingRepository repository,
  required AuthService auth,
  required int? branchId,
  required Future<void> Function() action,
}) async {
  if (_protectedOperationInFlight) return false;
  _protectedOperationInFlight = true;
  try {
    if (!await ensureBookingClosingAllowed(
      repository: repository,
      auth: auth,
      branchId: branchId,
    )) {
      return false;
    }
    await action();
    return true;
  } finally {
    _protectedOperationInFlight = false;
  }
}
