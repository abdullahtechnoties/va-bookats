// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:va_bookats/widgets/Global-Widgets/booking_card.dart';

class HomeController extends GetxController {
  final RxString searchQuery = ''.obs;

  final RxList<BookingCardModel> todayBookings = <BookingCardModel>[
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
      dateTime: 'Jan 24, 2026 | 03:00 PM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Today | 02.00 PM',
      totalAmount: '2200',
      services: ['Haircut', 'Massage'],
      status: 'Active',
    ),
    const BookingCardModel(
      id: '458',
      dateTime: 'Jan 24, 2026 | 05:00 PM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Today | 04.30 PM',
      totalAmount: '1800',
      services: ['Facial', 'Waxing'],
      status: 'Active',
    ),
    const BookingCardModel(
      id: '459',
      dateTime: 'Jan 24, 2026 | 06:30 PM',
      imageUrl: '',
      name: 'Name Here',
      location: 'Location Name Here',
      date: 'Today | 06.00 PM',
      totalAmount: '4000',
      services: ['Haircut', 'Facial', 'Massage'],
      status: 'Active',
    ),
  ].obs;

  final String vendorProfileImage = '';
  final int notificationCount = 3;
}