// lib/app/modules/payments/controllers/payments_controller.dart

import 'package:get/get.dart';
import 'package:va_bookats/widgets/Global-Widgets/payment_card.dart';

class PaymentsController extends GetxController {
  final RxList<PaymentCardModel> payments = <PaymentCardModel>[
    const PaymentCardModel(
      grandTotal: '2500.00',
      status: 'Paid',
      customerName: 'Shahid Mirza',
      customerEmail: 'shahidmirza123@gmail.com',
      customerPhone: '0345-6789100',
      branch: 'Nazimabad',
      total: '2500.00',
      paid: '1000.00',
      remaining: '1300.00',
    ),
    const PaymentCardModel(
      grandTotal: '2500.00',
      status: 'Paid',
      customerName: 'Shahid Mirza',
      customerEmail: 'shahidmirza123@gmail.com',
      customerPhone: '0345-6789100',
      branch: 'Nazimabad',
      total: '2500.00',
      paid: '1000.00',
      remaining: '1300.00',
    ),
    const PaymentCardModel(
      grandTotal: '2500.00',
      status: 'Paid',
      customerName: 'Shahid Mirza',
      customerEmail: 'shahidmirza123@gmail.com',
      customerPhone: '0345-6789100',
      branch: 'Nazimabad',
      total: '2500.00',
      paid: '1000.00',
      remaining: '1300.00',
    ),
    const PaymentCardModel(
      grandTotal: '1800.00',
      status: 'Pending',
      customerName: 'Ali Khan',
      customerEmail: 'alikhan@gmail.com',
      customerPhone: '0300-1234567',
      branch: 'Gulshan',
      total: '1800.00',
      paid: '500.00',
      remaining: '1300.00',
    ),
  ].obs;

  void deletePayment(int index) {
    payments.removeAt(index);
  }

  void openFilter() {
    // TODO: Open filter bottom sheet
  }
}