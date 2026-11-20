// lib/app/modules/dailyClosing/controllers/opening_balance_controller.dart
//
// Backs the floating "Today's opening balance" card on the home view.
//
// Owners may switch branches (mini selector); every other role is tied to
// the branch on their user model, so no selector is shown for them.

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/app/modules/dailyClosing/repositories/daily_closing_repository.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/daily_closing_form_sheet.dart';
import 'package:va_bookats/models/branch_model.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/utilities/permissions_helper.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class OpeningBalanceController extends GetxController {
  OpeningBalanceController({DailyClosingRepository? repository})
    : _repository = repository ?? DailyClosingRepository();

  final DailyClosingRepository _repository;
  final AuthService auth = Get.find<AuthService>();

  final Rxn<TodayClosing> today = Rxn<TodayClosing>();
  final RxBool isLoading = false.obs;
  final RxBool loadFailed = false.obs;

  /// Owner-only branch list / selection.
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final Rxn<BranchModel> selectedBranch = Rxn<BranchModel>();
  final RxBool isBranchesLoading = false.obs;
  bool _branchesLoaded = false;

  bool get isOwner => auth.isOwner;

  /// Owner → picked branch (falls back to their own branch id);
  /// everyone else → the branch on their user model.
  int? get branchId {
    if (isOwner) {
      return selectedBranch.value?.value ?? auth.currentUser.value?.branchId;
    }
    return auth.currentUser.value?.branchId;
  }

  /// Whether the current role can create today's opening balance.
  bool get canCreate => Permissions.can(AppPerm.create(AppPerm.dailyClosings));

  TodayClosing? get value => today.value;
  bool get hasOpening => today.value?.exists == true;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    if (isOwner && !_branchesLoaded) await loadBranches();
    await fetchToday();
  }

  Future<void> loadBranches() async {
    if (_branchesLoaded || isBranchesLoading.value) return;
    isBranchesLoading.value = true;
    final response = await _repository.getBranches();
    isBranchesLoading.value = false;
    if (!response.isCompleted || response.data == null) return;
    branches.assignAll(response.data!);
    _branchesLoaded = true;
    if (selectedBranch.value == null && branches.isNotEmpty) {
      final ownBranchId = auth.currentUser.value?.branchId;
      selectedBranch.value = branches.firstWhere(
        (b) => b.value == ownBranchId,
        orElse: () => branches.first,
      );
    }
  }

  Future<void> fetchToday() async {
    final id = branchId;
    if (id == null) {
      today.value = null;
      return;
    }
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repository.getToday(id);
    isLoading.value = false;
    if (isClosed) return;
    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      return;
    }
    today.value = response.data;
  }

  Future<void> refreshToday() async {
    if (isOwner && !_branchesLoaded) await loadBranches();
    await fetchToday();
  }

  Future<void> selectBranch(BranchModel branch) async {
    if (branch.value == selectedBranch.value?.value) return;
    selectedBranch.value = branch;
    today.value = null;
    await fetchToday();
  }

  /// Opens the create sheet for the selected branch (owner) or the user's
  /// own branch (other roles), then reloads the card.
  Future<void> openCreateSheet(BuildContext context) async {
    if (!canCreate) {
      showNoAccessDialog();
      return;
    }
    if (isOwner && !_branchesLoaded) {
      await loadBranches();
      if (isClosed || !context.mounted) return;
    }
    final id = branchId;
    if (id == null) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'dailyClosing.selectBranch'.trns(),
      );
      return;
    }
    final created = await DailyClosingFormSheet.show(
      context,
      branches: isOwner ? branches : const [],
      initialBranchId: id,
      allowBranchSelection: isOwner,
    );
    if (created != null) await fetchToday();
  }
}

/// Refreshes the home opening-balance card if it is mounted, so creating a
/// closing from the list/header instantly updates home too.
Future<void> refreshOpeningBalanceIfMounted() async {
  if (Get.isRegistered<OpeningBalanceController>()) {
    await Get.find<OpeningBalanceController>().refreshToday();
  }
}

/// Resolves the home card controller no matter which binding mounted the
/// route (`/bottomnav` registers it lazily, `/home` too). `Get.isRegistered`
/// alone is not enough: it only reports *instantiated* singletons, not
/// `Get.lazyPut` factories, which is why the card used to render nothing.
OpeningBalanceController ensureOpeningBalanceController() {
  if (Get.isRegistered<OpeningBalanceController>() ||
      Get.isPrepared<OpeningBalanceController>()) {
    return Get.find<OpeningBalanceController>();
  }
  return Get.put(OpeningBalanceController());
}
