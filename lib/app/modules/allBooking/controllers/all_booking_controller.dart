// lib/app/modules/all_booking/controllers/all_booking_controller.dart
import 'package:get/get.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_card.dart';

class AllBookingController extends GetxController {
  final RxInt selectedTab = 0.obs;

  final List<int> tabCounts = [21, 15, 6];

  final RxList<BookingCardModel> activeBookings = <BookingCardModel>[
    const BookingCardModel(
      id: '456',
      dateTime: 'Jan 24, 2026 | 01:30 PM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Today | 10.00 AM',
      totalAmount: '3500',
      services: ['Haircut', 'Facial', 'Waxing', 'Massage'],
      status: 'Active',
    ),
    const BookingCardModel(
      id: '456',
      dateTime: 'Jan 24, 2026 | 01:30 PM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Today | 10.00 AM',
      totalAmount: '3500',
      services: ['Haircut', 'Facial', 'Waxing', 'Massage'],
      status: 'Active',
    ),
    const BookingCardModel(
      id: '457',
      dateTime: 'Jan 25, 2026 | 02:00 PM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Today | 01.00 PM',
      totalAmount: '2800',
      services: ['Haircut', 'Facial'],
      status: 'Active',
    ),
  ].obs;

  final RxList<BookingCardModel> completedBookings = <BookingCardModel>[
    const BookingCardModel(
      id: '400',
      dateTime: 'Jan 20, 2026 | 10:00 AM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Jan 20 | 09.00 AM',
      totalAmount: '2000',
      services: ['Haircut', 'Massage'],
      status: 'Completed',
    ),
    const BookingCardModel(
      id: '401',
      dateTime: 'Jan 21, 2026 | 11:00 AM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Jan 21 | 10.00 AM',
      totalAmount: '3000',
      services: ['Facial', 'Waxing'],
      status: 'Completed',
    ),
  ].obs;

  final RxList<BookingCardModel> cancelledBookings = <BookingCardModel>[
    const BookingCardModel(
      id: '380',
      dateTime: 'Jan 18, 2026 | 09:00 AM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Jan 18 | 08.00 AM',
      totalAmount: '1500',
      services: ['Haircut'],
      status: 'Cancelled',
    ),
  ].obs;

  List<BookingCardModel> get currentBookings {
    switch (selectedTab.value) {
      case 0:
        return activeBookings;
      case 1:
        return completedBookings;
      case 2:
        return cancelledBookings;
      default:
        return activeBookings;
    }
  }
}