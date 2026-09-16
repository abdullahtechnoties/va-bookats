// lib/app/modules/mediaLibrary/controllers/media_library_controller.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:va_bookats/app/modules/mediaLibrary/repositories/media_repository.dart';
import 'package:va_bookats/models/media_model.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

/// UI wrapper around [MediaModel] so the existing grid/detail UI keeps working
/// while the data is now fully dynamic (media_id based).
class MediaItem {
  final int id;
  final String? networkUrl;
  final String? thumbnailUrl;
  final String name;
  final String uploadedDate;
  final String size;
  final String dimensions;
  final MediaModel? raw;

  MediaItem({
    required this.id,
    this.networkUrl,
    this.thumbnailUrl,
    required this.name,
    required this.uploadedDate,
    required this.size,
    required this.dimensions,
    this.raw,
  });

  factory MediaItem.fromModel(MediaModel m) {
    return MediaItem(
      id: m.id,
      networkUrl: m.url,
      thumbnailUrl: m.displayUrl,
      name: m.fileName.isEmpty ? 'media_${m.id}' : m.fileName,
      uploadedDate: m.uploadedLabel,
      size: m.sizeLabel,
      dimensions: m.dimensionsLabel,
      raw: m,
    );
  }

  /// Backwards-compat for callers that used String ids before.
  String get stringId => id.toString();

  bool get isLocal => false;
  File? get localFile => null;

  /// Media id to send to other APIs (`media_id`).
  int get mediaId => id;
}

class MediaLibraryController extends GetxController {
  MediaLibraryController({
    this.onSelectionConfirmed,
    this.isSheetMode = false,
    this.allowMultiple = true,
    List<int> initialSelectedIds = const [],
    MediaRepository? repository,
  })  : _repository = repository,
        _initialSelected = List<int>.from(initialSelectedIds);

  final Function(List<MediaItem>)? onSelectionConfirmed;
  final bool isSheetMode;
  final bool allowMultiple;
  final List<int> _initialSelected;
  final MediaRepository? _repository;

  MediaRepository get _repo {
    final repo = _repository;
    if (repo != null) return repo;
    if (Get.isRegistered<MediaRepository>()) {
      return Get.find<MediaRepository>();
    }
    return MediaRepository();
  }

  final RxList<MediaItem> mediaItems = <MediaItem>[].obs;
  final RxList<int> selectedIds = <int>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isUploading = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool loadFailed = false.obs;
  final RxBool hasMore = false.obs;
  final RxnInt busyDeleteId = RxnInt();
  final searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ImagePicker _picker = ImagePicker();
  Timer? _searchDebounce;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void onInit() {
    super.onInit();
    selectedIds.assignAll(_initialSelected);
    scrollController.addListener(_onScroll);
    // Debounced server search — typing filters via API.
    debounce<String>(
      searchQuery,
      (_) => fetchFirstPage(),
      time: const Duration(milliseconds: 500),
    );
    fetchFirstPage();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300 &&
        hasMore.value &&
        !isLoadingMore.value &&
        !isLoading.value) {
      loadMore();
    }
  }

  // ─── Fetching ──────────────────────────────────────────────────────────

  Future<void> fetchFirstPage() async {
    isLoading.value = true;
    loadFailed.value = false;
    final response = await _repo.getMedia(
      page: 1,
      search: searchQuery.value.trim().isEmpty
          ? null
          : searchQuery.value.trim(),
    );
    if (!response.isCompleted || response.data == null) {
      loadFailed.value = true;
      isLoading.value = false;
      // NetworkService already shows a snackbar; don't double-notify on
      // silent background refreshes — only when list is empty.
      if (mediaItems.isEmpty) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
      }
      return;
    }
    final page = response.data!;
    _currentPage = page.meta.currentPage;
    _lastPage = page.meta.lastPage;
    hasMore.value = page.meta.hasNextPage;
    mediaItems.assignAll(page.items.map(MediaItem.fromModel).toList());
    // Drop selections that no longer exist (e.g. after delete).
    selectedIds.retainWhere((id) => mediaItems.any((m) => m.id == id));
    isLoading.value = false;
  }

  Future<void> handleRefresh() async => fetchFirstPage();

  Future<void> loadMore() async {
    if (_currentPage >= _lastPage || isLoadingMore.value) return;
    isLoadingMore.value = true;
    final response = await _repo.getMedia(
      page: _currentPage + 1,
      search: searchQuery.value.trim().isEmpty
          ? null
          : searchQuery.value.trim(),
    );
    if (response.isCompleted && response.data != null) {
      final page = response.data!;
      _currentPage = page.meta.currentPage;
      _lastPage = page.meta.lastPage;
      hasMore.value = page.meta.hasNextPage;
      mediaItems.addAll(page.items.map(MediaItem.fromModel).toList());
    }
    isLoadingMore.value = false;
  }

  void retry() => fetchFirstPage();

  List<MediaItem> get filteredItems {
    // Server already filters by `search`; keep a light client filter so the
    // in-sheet search dialog feels instant while the debounce fires.
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return mediaItems;
    // If server returned a filtered set, client filtering is a no-op pass.
    final clientHit =
        mediaItems.where((m) => m.name.toLowerCase().contains(q)).toList();
    return clientHit.isEmpty ? mediaItems : clientHit;
  }

  MediaItem? get firstSelected {
    if (selectedIds.isEmpty) return null;
    try {
      return mediaItems.firstWhere((m) => m.id == selectedIds.first);
    } catch (_) {
      return null;
    }
  }

  List<MediaItem> get selectedItems =>
      mediaItems.where((m) => selectedIds.contains(m.id)).toList();

  bool isSelected(int id) => selectedIds.contains(id);

  /// Backwards-compat overload — old UI passed String ids.
  bool isSelectedString(String id) =>
      selectedIds.contains(int.tryParse(id) ?? -1);

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      if (!allowMultiple) selectedIds.clear();
      selectedIds.add(id);
    }
  }

  /// Backwards-compat for old String-based callers.
  void toggleSelectionString(String id) {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    toggleSelection(parsed);
  }

  void clearSelection() => selectedIds.clear();

  // ─── Upload ────────────────────────────────────────────────────────────

  Future<void> uploadFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();
      if (files.isEmpty) return;
      await _uploadFiles(files.map((f) => File(f.path)).toList());
    } catch (_) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'errors.imagePickerGallery'.trns(),
      );
    }
  }

  Future<void> uploadFromCamera() async {
    try {
      final XFile? file =
          await _picker.pickImage(source: ImageSource.camera);
      if (file == null) return;
      await _uploadFiles([File(file.path)]);
    } catch (_) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'errors.imagePickerCamera'.trns(),
      );
    }
  }

  Future<void> _uploadFiles(List<File> files) async {
    isUploading.value = true;
    try {
      final response = await _repo.uploadMedia(files);
      if (!response.isCompleted || response.data == null) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: response.message ?? 'errors.requestFailed'.trns(),
        );
        return;
      }
      final uploaded =
          response.data!.map(MediaItem.fromModel).toList();
      // Newest first — matches the API's recent-first ordering.
      mediaItems.insertAll(0, uploaded);
      // Auto-select uploads so the sheet reflects the new image instantly.
      if (!allowMultiple && uploaded.isNotEmpty) {
        selectedIds.assignAll([uploaded.first.id]);
      } else {
        for (final item in uploaded) {
          if (!selectedIds.contains(item.id)) selectedIds.add(item.id);
        }
      }
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'mediaLibrary.uploadSuccess'.trns(),
      );
    } finally {
      isUploading.value = false;
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────

  Future<void> deleteItem(int id) async {
    busyDeleteId.value = id;
    final response = await _repo.deleteMedia([id]);
    busyDeleteId.value = null;
    if (response.isCompleted) {
      mediaItems.removeWhere((m) => m.id == id);
      selectedIds.remove(id);
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'mediaLibrary.deleteSuccess'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  /// Backwards-compat for old String-based callers.
  Future<void> deleteItemString(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    return deleteItem(parsed);
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;
    final ids = List<int>.from(selectedIds);
    busyDeleteId.value = ids.first;
    final response = await _repo.deleteMedia(ids);
    busyDeleteId.value = null;
    if (response.isCompleted) {
      mediaItems.removeWhere((m) => ids.contains(m.id));
      selectedIds.clear();
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'mediaLibrary.deleteSuccess'.trns(),
      );
    } else {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: response.message ?? 'errors.requestFailed'.trns(),
      );
    }
  }

  // ─── Selection ─────────────────────────────────────────────────────────

  void confirmSelection() {
    final selected = selectedItems;
    onSelectionConfirmed?.call(selected);
    Get.back();
  }
}
