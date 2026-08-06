// import 'dart:io';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_compress/video_compress.dart';

// /// Utility class for compressing images and videos before upload.
// /// Reduces file sizes significantly, improving upload speed and story/post loading.
// class MediaCompressor {
//   MediaCompressor._();

//   /// Compresses an image file.
//   /// Returns the compressed file, or the original if compression fails.
//   static Future<File> compressImage(File file, {int quality = 70, int maxWidth = 1080}) async {
//     try {
//       final dir = await getTemporaryDirectory();
//       final targetPath =
//           '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

//       final result = await FlutterImageCompress.compressAndGetFile(
//         file.absolute.path,
//         targetPath,
//         quality: quality,
//         minWidth: maxWidth,
//         minHeight: maxWidth,
//       );

//       if (result != null) {
//         return File(result.path);
//       }
//       return file;
//     } catch (_) {
//       return file;
//     }
//   }

//   /// Compresses a video file using medium quality.
//   /// Returns the compressed file, or the original if compression fails.
//   static Future<File> compressVideo(File file) async {
//     try {
//       final info = await VideoCompress.compressVideo(
//         file.path,
//         quality: VideoQuality.MediumQuality,
//         deleteOrigin: false,
//         includeAudio: true,
//       );

//       if (info != null && info.file != null) {
//         return info.file!;
//       }
//       return file;
//     } catch (_) {
//       return file;
//     }
//   }

//   /// Auto-detects media type and compresses accordingly.
//   static Future<File> compressMedia(File file, {bool? isVideo}) async {
//     final bool video = isVideo ?? _isVideoFile(file.path);
//     if (video) {
//       return compressVideo(file);
//     }
//     return compressImage(file);
//   }

//   /// Checks if a file path points to a video file.
//   static bool _isVideoFile(String path) {
//     final lower = path.toLowerCase();
//     return lower.endsWith('.mp4') ||
//         lower.endsWith('.mov') ||
//         lower.endsWith('.avi') ||
//         lower.endsWith('.webm') ||
//         lower.endsWith('.mkv');
//   }

//   /// Checks if a file path points to an image file.
//   static bool isImageFile(String path) {
//     final lower = path.toLowerCase();
//     return lower.endsWith('.jpg') ||
//         lower.endsWith('.jpeg') ||
//         lower.endsWith('.png') ||
//         lower.endsWith('.gif') ||
//         lower.endsWith('.webp') ||
//         lower.endsWith('.bmp');
//   }

//   /// Cancel any ongoing video compression.
//   static Future<void> cancelCompression() async {
//     await VideoCompress.cancelCompression();
//   }
// }
