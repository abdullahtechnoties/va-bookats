// lib/app/modules/booking_details/controllers/booking_details_controller.dart

import 'package:get/get.dart';

class BookingDetailsController extends GetxController {
  final RxBool isCustomerInfoExpanded = true.obs;

  // Booking Info
  final String bookingId = '456';
  final String bookingDateTime = 'Jan 24, 2026 | 01:30 PM';
  final String branchName = 'Branch Name';
  final String branchLocation = 'Nazimabad';
  final String branchImageUrl = '';
  final List<String> services = ['Haircut', 'Facial', 'Waxing', 'Massage'];
  final String timeDuration = '5:00 PM - 6:00 PM';
  final String email = 'demo@owner.com';
  final String phoneNumber = '07576775';

  // Customer Info
  final String customerName = 'Shahid Mirza';
  final String customerEmail = 'demo@owner.com';
  final String customerPhone = '07576775';

  // Price Breakdown
  final String totalPrice = '2300.00';
  final String servicesDetail = 'Hair Cut & Blow Dry';
  final String staff = 'shahidmirza123@gmail.com';
  final String categories = '0345-6789100';
  final String variation = 'Nazimabad';
  final String price = '2500.00';
  final String qty = '1000.00';
  final String total = '1300.00';
  final String discount = '2500.00';
  final String afterDiscount = '2300.00';

  // Grand Total
  final String grandTotal = '2500.00';
  final String paymentStatus = 'Paid';
  final String grandCustomerName = 'Shahid Mirza';
  final String grandCustomerEmail = 'shahidmirza123@gmail.com';
  final String grandCustomerPhone = '0345-6789100';
  final String branch = 'Nazimabad';
  final String grandTotalTotal = '2500.00';
  final String paid = '1000.00';
  final String remaining = '1300.00';

  void toggleCustomerInfo() {
    isCustomerInfoExpanded.value = !isCustomerInfoExpanded.value;
  }
}