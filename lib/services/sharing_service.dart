import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/documentation_item.dart';
import '../utils/time_utils.dart';

class SharingService {
  /// Format the standard WhatsApp caption text:
  /// 10B | nama orang | 31/10/2026
  ///
  /// Subuh: 04:31
  /// Maghrib: 18:31
  /// Isya: 19:59
  static String formatCaption(DocumentationItem item) {
    final dateStr = TimeUtils.formatDateSlash(item.timestamp);
    final nameStr = item.studentName.trim().isNotEmpty
        ? item.studentName.trim()
        : '-';

    final subuhTime = item.photoTimestamps.isNotEmpty
        ? TimeUtils.formatTime(item.photoTimestamps[0])
        : '-';
    final maghribTime = item.photoTimestamps.length > 1
        ? TimeUtils.formatTime(item.photoTimestamps[1])
        : '-';
    final isyaTime = item.photoTimestamps.length > 2
        ? TimeUtils.formatTime(item.photoTimestamps[2])
        : '-';

    final buffer = StringBuffer();
    buffer.writeln('10B | $nameStr | $dateStr');
    buffer.writeln();
    buffer.writeln('Subuh: $subuhTime');
    buffer.writeln('Maghrib: $maghribTime');
    buffer.writeln('Isya: $isyaTime');

    return buffer.toString().trim();
  }

  /// Trigger native OS / Web share sheet with collage image and caption
  static Future<bool> shareDocumentation(DocumentationItem item) async {
    try {
      final caption = formatCaption(item);

      if (kIsWeb || item.collageImagePath.startsWith('data:image')) {
        XFile? xFile;
        if (item.collageImagePath.startsWith('data:image')) {
          final commaIndex = item.collageImagePath.indexOf(',');
          final base64Str = commaIndex != -1
              ? item.collageImagePath.substring(commaIndex + 1)
              : item.collageImagePath;
          final bytes = base64Decode(base64Str);
          xFile = XFile.fromData(
            bytes,
            mimeType: 'image/jpeg',
            name: 'sholat_sigma_${item.timestamp.millisecondsSinceEpoch}.jpg',
          );
        }

        if (xFile != null) {
          final result = await Share.shareXFiles(
            [xFile],
            text: caption,
            subject: item.title,
          );
          return result.status == ShareResultStatus.success ||
              result.status == ShareResultStatus.dismissed;
        } else {
          final result = await Share.share(
            caption,
            subject: item.title,
          );
          return result.status == ShareResultStatus.success ||
              result.status == ShareResultStatus.dismissed;
        }
      }

      final file = File(item.collageImagePath);
      if (!await file.exists()) {
        debugPrint('File kolase tidak ditemukan di ${item.collageImagePath}');
        return false;
      }

      final xFile = XFile(item.collageImagePath, mimeType: 'image/jpeg');

      final result = await Share.shareXFiles(
        [xFile],
        text: caption,
        subject: item.title,
      );

      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('Kesalahan saat membagikan: $e');
      return false;
    }
  }
}
