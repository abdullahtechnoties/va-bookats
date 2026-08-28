import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:va_bookats/utilities/snackbar_service.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class MediaItem {
  final String id;
  final String? networkUrl;
  final File? localFile;
  final String name;
  final String uploadedDate;
  final String size;
  final String dimensions;

  MediaItem({
    required this.id,
    this.networkUrl,
    this.localFile,
    required this.name,
    required this.uploadedDate,
    required this.size,
    required this.dimensions,
  });

  bool get isLocal => localFile != null;
}

class MediaLibraryController extends GetxController {
  final RxList<MediaItem> mediaItems = <MediaItem>[].obs;
  final RxList<String> selectedIds = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isUploading = false.obs;
  final searchController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  // Callback when selecting from sheet mode
  final Function(List<MediaItem>)? onSelectionConfirmed;
  final bool isSheetMode;

  MediaLibraryController({
    this.onSelectionConfirmed,
    this.isSheetMode = false,
  });

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy network images (salon-themed unsplash)
    final dummyUrls = [
      'https://images.unsplash.com/photo-1560066984-138daaa5fd72?w=400',
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
      'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=400',
      'https://images.unsplash.com/photo-1559599101-f09722fb4948?w=400',
      'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400',
      'https://images.unsplash.com/photo-1634449571010-02389ed0f9b0?w=400',
      'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=400',
      'https://images.unsplash.com/photo-1470259078422-826894b933aa?w=400',
    ];

    mediaItems.value = dummyUrls.asMap().entries.map((e) {
      return MediaItem(
        id: 'item_${e.key}',
        networkUrl: e.value,
        name: 'temp${e.key + 1}.webp',
        uploadedDate: 'Aug 27, 2026',
        size: '${(30 + e.key * 7).toStringAsFixed(2)} KB',
        dimensions: '1920 x 1080',
      );
    }).toList();
  }

  List<MediaItem> get filteredItems {
    if (searchQuery.value.isEmpty) return mediaItems;
    return mediaItems
        .where((m) =>
            m.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  MediaItem? get firstSelected {
    if (selectedIds.isEmpty) return null;
    try {
      return mediaItems.firstWhere((m) => m.id == selectedIds.first);
    } catch (_) {
      return null;
    }
  }

  bool isSelected(String id) => selectedIds.contains(id);

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void clearSelection() => selectedIds.clear();

  Future<void> uploadFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();
      if (files.isEmpty) return;
      isUploading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      for (final file in files) {
        final newItem = MediaItem(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}_${file.name}',
          localFile: File(file.path),
          name: file.name,
          uploadedDate: _todayFormatted(),
          size: '${((await File(file.path).length()) / 1024).toStringAsFixed(2)} KB',
          dimensions: 'Unknown',
        );
        mediaItems.insert(0, newItem);
      }
      isUploading.value = false;
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'mediaLibrary.uploadSuccess'.trns(),
      );
    } catch (_) {
      isUploading.value = false;
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
      isUploading.value = true;
      await Future.delayed(const Duration(milliseconds: 600));

      final newItem = MediaItem(
        id: 'cam_${DateTime.now().millisecondsSinceEpoch}',
        localFile: File(file.path),
        name: file.name,
        uploadedDate: _todayFormatted(),
        size: '${((await File(file.path).length()) / 1024).toStringAsFixed(2)} KB',
        dimensions: 'Unknown',
      );
      mediaItems.insert(0, newItem);
      isUploading.value = false;
    } catch (_) {
      isUploading.value = false;
    }
  }

  void deleteItem(String id) {
    mediaItems.removeWhere((m) => m.id == id);
    selectedIds.remove(id);
    SnackbarService.showSuccess(
      title: 'common.success'.trns(),
      message: 'mediaLibrary.deleteSuccess'.trns(),
    );
  }

  void confirmSelection() {
    final selected = mediaItems
        .where((m) => selectedIds.contains(m.id))
        .toList();
    onSelectionConfirmed?.call(selected);
    Get.back();
  }

  String _todayFormatted() {
    final now = DateTime.now();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month]} ${now.day}, ${now.year}';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}