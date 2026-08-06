import 'package:va_bookats/network/api/api_path.dart';

String? getImage(String? image) {
      if (image == null) return null;
      if (image.startsWith('http')) return image;
      return '${ApiPath.imageUrl}/$image';
    }