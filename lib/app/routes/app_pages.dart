import 'package:get/get.dart';

import '../modules/addPackage/bindings/add_package_binding.dart';
import '../modules/addPackage/views/add_package_view.dart';
import '../modules/addService/bindings/add_service_binding.dart';
import '../modules/addService/views/add_service_view.dart';
import '../modules/addServiceCategory/bindings/add_service_category_binding.dart';
import '../modules/addServiceCategory/views/add_service_category_view.dart';
import '../modules/allBooking/bindings/all_booking_binding.dart';
import '../modules/allBooking/views/all_booking_view.dart';
import '../modules/appDrawer/bindings/app_drawer_binding.dart';
import '../modules/appDrawer/views/app_drawer_view.dart';
import '../modules/bookingDetails/bindings/booking_details_binding.dart';
import '../modules/bookingDetails/views/booking_details_view.dart';
import '../modules/bottomnav/bindings/bottomnav_binding.dart';
import '../modules/bottomnav/views/bottomnav_view.dart';
import '../modules/branchComparison/bindings/branch_comparison_binding.dart';
import '../modules/branchComparison/views/branch_comparison_view.dart';
import '../modules/createBooking/bindings/create_booking_binding.dart';
import '../modules/createBooking/views/create_booking_view.dart';
import '../modules/customers/bindings/customers_binding.dart';
import '../modules/customers/views/customers_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/mediaLibrary/bindings/media_library_binding.dart';
import '../modules/mediaLibrary/views/media_library_view.dart';
import '../modules/onboard/bindings/onboard_binding.dart';
import '../modules/onboard/views/onboard_view.dart';
import '../modules/packages/bindings/packages_binding.dart';
import '../modules/packages/views/packages_view.dart';
import '../modules/paymentDetails/bindings/payment_details_binding.dart';
import '../modules/paymentDetails/views/payment_details_view.dart';
import '../modules/payments/bindings/payments_binding.dart';
import '../modules/payments/views/payments_view.dart';
import '../modules/personalInfo/bindings/personal_info_binding.dart';
import '../modules/personalInfo/views/personal_info_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/revenueReport/bindings/revenue_report_binding.dart';
import '../modules/revenueReport/views/revenue_report_view.dart';
import '../modules/serviceCategories/bindings/service_categories_binding.dart';
import '../modules/serviceCategories/views/service_categories_view.dart';
import '../modules/services/bindings/services_binding.dart';
import '../modules/services/views/services_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/updatePassword/bindings/update_password_binding.dart';
import '../modules/updatePassword/views/update_password_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

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
    GetPage(
      name: _Paths.SERVICES,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: _Paths.ADD_SERVICE,
      page: () => const AddServiceView(),
      binding: AddServiceBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_CATEGORIES,
      page: () => const ServiceCategoriesView(),
      binding: ServiceCategoriesBinding(),
    ),
    GetPage(
      name: _Paths.ADD_SERVICE_CATEGORY,
      page: () => const AddServiceCategoryView(),
      binding: AddServiceCategoryBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGES,
      page: () => const PackagesView(),
      binding: PackagesBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PACKAGE,
      page: () => const AddPackageView(),
      binding: AddPackageBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMERS,
      page: () => const CustomersView(),
      binding: CustomersBinding(),
    ),
    GetPage(
      name: _Paths.REVENUE_REPORT,
      page: () => const RevenueReportView(),
      binding: RevenueReportBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOMNAV,
      page: () => BottomnavView(),
      binding: BottomnavBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARD,
      page: () => const OnboardView(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.APP_DRAWER,
      page: () => const AppDrawerView(),
      binding: AppDrawerBinding(),
    ),
    GetPage(
      name: _Paths.PERSONAL_INFO,
      page: () => const PersonalInfoView(),
      binding: PersonalInfoBinding(),
    ),
    GetPage(
      name: _Paths.UPDATE_PASSWORD,
      page: () => const UpdatePasswordView(),
      binding: UpdatePasswordBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_DETAILS,
      page: () => const PaymentDetailsView(),
      binding: PaymentDetailsBinding(),
    ),
    GetPage(
      name: _Paths.MEDIA_LIBRARY,
      page: () => const MediaLibraryView(),
      binding: MediaLibraryBinding(),
    ),
    GetPage(
      name: _Paths.BRANCH_COMPARISON,
      page: () => const BranchComparisonView(),
      binding: BranchComparisonBinding(),
    ),
  ];
}
