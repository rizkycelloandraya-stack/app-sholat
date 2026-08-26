import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/documentation_item.dart';
import '../utils/time_utils.dart';

class SharingService {
  /// Format the standard WhatsApp caption text with Student Name, Date, Location, Notes & 3-Prayer breakdown
  static String formatCaption(DocumentationItem item) {
    final dateStr = TimeUtils.formatDateIndonesian(item.timestamp);
    final locationStr = item.locationName.isNotEmpty
        ? item.locationName
        : 'Lokasi tidak tersedia';

    final buffer = StringBuffer();
    buffer.writeln('🕌 *SHOLAT SIGMA - DOKUMENTASI SHOLAT 3 WAKTU*');
    buffer.writeln();
    if (item.studentName.isNotEmpty) {
      buffer.writeln('👤 *Nama*: ${item.studentName}');
    }
    buffer.writeln('📅 *Tanggal*: $dateStr');
    buffer.writeln('📍 *Tempat/Lokasi*: $locationStr');

    if (item.description.isNotEmpty && item.description != item.title) {
      buffer.writeln('📝 *Keterangan*: ${item.description}');
    }

    buffer.writeln();
    buffer.writeln('📸 *Rincian Foto Sholat:*');
    if (item.photoTimestamps.isNotEmpty) {
      buffer.writeln('1. Sholat Subuh: ${TimeUtils.formatTime(item.photoTimestamps[0])} WIB');
    }
    if (item.photoTimestamps.length > 1) {
      buffer.writeln('2. Sholat Maghrib: ${TimeUtils.formatTime(item.photoTimestamps[1])} WIB');
    }
    if (item.photoTimestamps.length > 2) {
      buffer.writeln('3. Sholat Isya: ${TimeUtils.formatTime(item.photoTimestamps[2])} WIB');
    }

    return buffer.toString().trim();
  }

  /// Trigger native OS share sheet with collage image and caption
  static Future<bool> shareDocumentation(DocumentationItem item) async {
    try {
      final file = File(item.collageImagePath);
      if (!await file.exists()) {
        debugPrint('File kolase tidak ditemukan di ${item.collageImagePath}');
        return false;
      }

      final caption = formatCaption(item);
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
