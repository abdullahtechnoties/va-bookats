import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/bookings/repositories/booking_repository.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

Future<bool> ensureBookingClosingAllowed({
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
