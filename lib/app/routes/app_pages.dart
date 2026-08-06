import 'package:get/get.dart';

import '../modules/allBooking/bindings/all_booking_binding.dart';
import '../modules/allBooking/views/all_booking_view.dart';
import '../modules/bookingDetails/bindings/booking_details_binding.dart';
import '../modules/bookingDetails/views/booking_details_view.dart';
import '../modules/createBooking/bindings/create_booking_binding.dart';
import '../modules/createBooking/views/create_booking_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/payments/bindings/payments_binding.dart';
import '../modules/payments/views/payments_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.ALL_BOOKING,
      page: () => const AllBookingView(),
      binding: AllBookingBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING_DETAILS,
      page: () => const BookingDetailsView(),
      binding: BookingDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENTS,
      page: () => const PaymentsView(),
      binding: PaymentsBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_BOOKING,
      page: () => const CreateBookingView(),
      binding: CreateBookingBinding(),
    ),
  ];
}
