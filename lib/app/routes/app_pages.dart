import 'package:get/get.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/paymentDetails/bindings/payment_details_binding.dart';
import 'package:va_bookats/app/modules/reporting/branch_comparison/paymentDetails/views/payment_details_view.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commisionReportDetails/bindings/commissions_detail_binding.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commisionReportDetails/views/commissions_detail_view.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/bindings/commissions_report_binding.dart';
import 'package:va_bookats/app/modules/reporting/commision_report/commissionReport/views/commision_report_view.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/bindings/customer_report_binding.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReport/views/customer_report_view.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReportDetails/bindings/customer_details_binding.dart';
import 'package:va_bookats/app/modules/reporting/customer_report/customerReportDetails/views/customer_details_view.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/bindings/expense_report_binding.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReport/views/expense_report_view.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReportDetails/bindings/expense_detail_binding.dart';
import 'package:va_bookats/app/modules/reporting/expense_report/expenseReportDetails/views/expense_detail_view.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueDetails/bindings/product_revenue_details_binding.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueDetails/views/product_revenue_details_view.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/bindings/product_revenue_report_binding.dart';
import 'package:va_bookats/app/modules/reporting/product_revenue_report/productRevenueReport/views/product_revenue_report_view.dart';
import 'package:va_bookats/app/modules/reporting/service_revenue_report/serviceRevenueReport/views/service_revenue_report_view.dart';

import '../modules/addCustomer/bindings/add_customer_binding.dart';
import '../modules/addCustomer/views/add_customer_view.dart';
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
import '../modules/reporting/branch_comparison/branchComparison/bindings/branch_comparison_binding.dart';
import '../modules/reporting/branch_comparison/branchComparison/views/branch_comparison_view.dart';
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
import '../modules/reporting/package_revenue_report/packageRevenueReport/bindings/package_revenue_report_binding.dart';
import '../modules/reporting/package_revenue_report/packageRevenueReport/views/package_revenue_report_view.dart';
import '../modules/reporting/package_revenue_report/packageRevenueReportDetails/bindings/package_revenue_details_binding.dart';
import '../modules/reporting/package_revenue_report/packageRevenueReportDetails/views/package_revenue_details_view.dart';
import '../modules/reporting/revenue_report/paymentDetails/bindings/payment_details_binding.dart';
import '../modules/reporting/revenue_report/paymentDetails/views/payment_details_view.dart';
import '../modules/payments/bindings/payments_binding.dart';
import '../modules/payments/views/payments_view.dart';
import '../modules/personalInfo/bindings/personal_info_binding.dart';
import '../modules/personalInfo/views/personal_info_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/reporting/revenue_report/revenueReport/bindings/revenue_report_binding.dart';
import '../modules/reporting/revenue_report/revenueReport/views/revenue_report_view.dart';
import '../modules/reporting/service_revenue_report/serviceRevenueDetails/bindings/service_revenue_details.dart';
import '../modules/reporting/service_revenue_report/serviceRevenueDetails/views/service_revenue_details.dart';
import '../modules/reporting/service_revenue_report/serviceRevenueReport/bindings/service_revenue_report.dart';
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
      name: _Paths.ADD_CUSTOMER,
      page: () => const AddCustomerView(),
      binding: AddCustomerBinding(),
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
      name: _Paths.BRANCH_COMPARISON_REPORT,
      page: () => const BranchComparisonReportView(),
      binding: BranchComparisonReportBinding(),
    ),
    GetPage(
      name: _Paths.BRANCH_COMPARISON_REPORT_DETAILS,
      page: () => const BranchComparisonReportDetailsView(),
      binding: BranchComparisonReportDetailsBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_REVENUE_REPORT,
      page: () => const ServiceRevenueReportView(),
      binding: ServiceRevenueReportBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_REVENUE_DETAILS,
      page: () => const ServiceRevenueDetailsView(),
      binding: ServiceRevenueDetailsBinding(),
    ),
    GetPage(
      name: Routes.PRODUCT_REVENUE_REPORT,
      page: () => const ProductRevenueReportView(),
      binding: ProductRevenueReportBinding(),
    ),
    GetPage(
      name: Routes.PRODUCT_REVENUE_DETAILS,
      page: () => const ProductRevenueDetailsView(),
      binding: ProductRevenueDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGE_REVENUE_REPORT,
      page: () => const PackageRevenueReportView(),
      binding: PackageRevenueReportBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGE_REVENUE_DETAILS,
      page: () => const PackageRevenueDetailsView(),
      binding: PackageRevenueDetailsBinding(),
    ),
    GetPage(
      name: _Paths.COMMISSIONS_REPORT,
      page: () => const CommissionsReportView(),
      binding: CommissionsReportBinding(),
    ),
    GetPage(
      name: _Paths.COMMISSIONS_DETAIL,
      page: () => const CommissionsDetailView(),
      binding: CommissionsDetailBinding(),
    ),
    GetPage(
      name: _Paths.EXPENSE_REPORT,
      page: () => const ExpenseReportView(),
      binding: ExpenseReportBinding(),
    ),
    GetPage(
      name: _Paths.EXPENSE_DETAIL,
      page: () => const ExpenseDetailView(),
      binding: ExpenseDetailBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_REPORT,
      page: () => const CustomerReportView(),
      binding: CustomerReportBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_DETAILS,
      page: () => const CustomerDetailsView(),
      binding: CustomerDetailsBinding(),
    ),
  ];
}
