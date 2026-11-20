// lib/app/modules/dailyClosing/controllers/daily_closing_details_controller.dart
//
// Detail screen controller. The endpoint returns one paginator per tab, so
// each section is kept separately and can append its own next page without
// refetching the whole payload.

import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/closing_status_sheet.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class DailyClosingDetailsController extends GetxController {
  DailyClosingDetailsController({DailyClosingRepository? repository})
    : _repository = repository ?? DailyClosingRepository();

  final DailyClosingRepository _repository;
  final AuthService auth = Get.find<AuthService>();

  final RxnInt id = RxnInt();

  final Rxn<DailyClosingModel> closing = Rxn<DailyClosingModel>();
  final RxList<ClosingActivity> activities = <ClosingActivity>[].obs;
  final Rx<RawSection> bookings = RawSection.empty.obs;
  final Rx<RawSection> payments = RawSection.empty.obs;
  final Rx<RawSection> staffCommissions = RawSection.empty.obs;
  final Rx<RawSection> expenses = RawSection.empty.obs;
  final Rx<RawSection> serviceSummary = RawSection.empty.obs;
  final Rx<RawSection> productSummary = RawSection.empty.obs;
  final Rx<RawSection> packageSummary = RawSection.empty.obs;
  final Rx<RawSection> cashFlow = RawSection.empty.obs;

  final RxString cashIn = '0'.obs;
  final RxString cashOut = '0'.obs;
  final RxString cashNet = '0'.obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool loadFailed = false.obs;
  final RxnInt busyStatusId = RxnInt();
  final RxSet<ClosingSection> loadingSections = <ClosingSection>{}.obs;

  bool get canUpdate => Permissions.can(AppPerm.update(AppPerm.dailyClosings));

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      id.value = args;
    } else if (args is DailyClosingModel) {
      id.value = args.id;
      closing.value = args;
    }
    if (id.value != null) fetchDetail();
  }

  Future<void> fetchDetail() async {
    final closingId = id.value;
    if (closingId == null) return;
    isLoading.value = closing.value == null;
    loadFailed.value = false;

    final response = await _repository.getDetail(closingId);
    if (isClosed) return;

    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      return;
    }
    _apply(response.data!);
    isLoading.value = false;
  }

  Future<void> refreshDetail() async {
    isRefreshing.value = true;
    await fetchDetail();
    isRefreshing.value = false;
  }

  void retry() => fetchDetail();

  void _apply(DailyClosingDetail detail) {
    closing.value = detail.closing;
    activities.assignAll(detail.activities);
    bookings.value = detail.bookings;
    payments.value = detail.payments;
    staffCommissions.value = detail.staffCommissions;
    expenses.value = detail.expenses;
    serviceSummary.value = detail.serviceSummary;
    productSummary.value = detail.productSummary;
    packageSummary.value = detail.packageSummary;
    cashFlow.value = detail.cashFlow;
    cashIn.value = detail.cashIn;
    cashOut.value = detail.cashOut;
    cashNet.value = detail.cashNet;
  }

  RawSection sectionOf(ClosingSection section) {
    switch (section) {
      case ClosingSection.bookings:
        return bookings.value;
      case ClosingSection.payments:
        return payments.value;
      case ClosingSection.staffCommissions:
        return staffCommissions.value;
      case ClosingSection.expenses:
        return expenses.value;
      case ClosingSection.services:
        return serviceSummary.value;
      case ClosingSection.products:
        return productSummary.value;
      case ClosingSection.packages:
        return packageSummary.value;
      case ClosingSection.cashFlow:
        return cashFlow.value;
      default:
        return RawSection.empty;
    }
  }

  void _setSection(ClosingSection section, RawSection value) {
    switch (section) {
      case ClosingSection.bookings:
        bookings.value = value;
        break;
      case ClosingSection.payments:
        payments.value = value;
        break;
      case ClosingSection.staffCommissions:
        staffCommissions.value = value;
        break;
      case ClosingSection.expenses:
        expenses.value = value;
        break;
      case ClosingSection.services:
        serviceSummary.value = value;
        break;
      case ClosingSection.products:
        productSummary.value = value;
        break;
      case ClosingSection.packages:
        packageSummary.value = value;
        break;
      case ClosingSection.cashFlow:
        cashFlow.value = value;
        break;
      default:
        break;
    }
  }

  /// Appends the next page of one section (per-tab "Load more").
  Future<void> loadMore(ClosingSection section) async {
    final closingId = id.value;
    if (closingId == null || loadingSections.contains(section)) return;
    final current = sectionOf(section);
    if (!current.meta.hasNextPage) return;

    loadingSections.add(section);
    final response = await _repository.getDetail(
      closingId,
      section: section,
      page: current.meta.currentPage + 1,
    );
    loadingSections.remove(section);
    if (isClosed) return;
    if (!response.isCompleted || response.data == null) return;

    final fresh = sectionFromDetail(response.data!, section);
    _setSection(
      section,
      RawSection(items: [...current.items, ...fresh.items], meta: fresh.meta),
    );
  }

  /// Extracts one paginator from a detail payload (used by "Load more").
  RawSection sectionFromDetail(
    DailyClosingDetail detail,
    ClosingSection section,
  ) {
    switch (section) {
      case ClosingSection.bookings:
        return detail.bookings;
      case ClosingSection.payments:
        return detail.payments;
      case ClosingSection.staffCommissions:
        return detail.staffCommissions;
      case ClosingSection.expenses:
        return detail.expenses;
      case ClosingSection.services:
        return detail.serviceSummary;
      case ClosingSection.products:
        return detail.productSummary;
      case ClosingSection.packages:
        return detail.packageSummary;
      case ClosingSection.cashFlow:
        return detail.cashFlow;
      default:
        return RawSection.empty;
    }
  }

  Future<void> changeStatus() async {
    final item = closing.value;
    if (item == null) return;
    if (!canUpdate) {
      showNoAccessDialog();
      return;
    }
    if (busyStatusId.value != null) return;

    final target = await showClosingStatusSheet(currentStatus: item.status);
    if (target == null) return;
    if (target.toLowerCase() == item.status.toLowerCase()) return;

    busyStatusId.value = item.id;
    final response = await _repository.changeStatus(item.id);
    busyStatusId.value = null;
    if (isClosed) return;

    if (response.isCompleted) {
      final status = (response.data ?? '').isNotEmpty ? response.data! : target;
      closing.value = item.copyWith(status: status);
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: response.message ?? 'dailyClosing.statusUpdated'.trns(),
      );
      // Approver + activity timeline changed on the server.
      await fetchDetail();
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }
}
