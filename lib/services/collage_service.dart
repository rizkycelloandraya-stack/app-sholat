import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/photo_capture.dart';
import '../utils/time_utils.dart';

class CollageService {
  static const int canvasWidth = 1080;
  static const int canvasHeight = 1520;
  static const int padding = 20;

  /// Generates a professional 3-photo collage with clean photo metadata
  /// containing Tanggal, Lokasi foto diambil, and Jam foto diambil.
  static Future<String> generateCollage({
    required List<PhotoCapture> captures,
    required String studentName,
    required String activityTitle,
    required String description,
    required DateTime documentationTimestamp,
    required String locationName,
    String districtProvince = '',
    String fullAddress = '',
    double? latitude,
    double? longitude,
  }) async {
    if (captures.length < 3) {
      throw Exception('Tepat 3 foto (Subuh, Maghrib, Isya) diperlukan untuk membuat kolase dokumentasi.');
    }

    final lat = latitude ?? -6.92969;
    final lng = longitude ?? 107.721869;
    final distProv = districtProvince.isNotEmpty ? districtProvince : locationName;

    // 1. Load and normalize individual photos
    final img1 = await _loadAndNormalize(captures[0].filePath, 1080, 720);
    final img2 = await _loadAndNormalize(captures[1].filePath, 540, 420);
    final img3 = await _loadAndNormalize(captures[2].filePath, 540, 420);

    // 2. Create base canvas with dark slate aesthetic
    final canvas = img.Image(
      width: canvasWidth,
      height: canvasHeight,
      numChannels: 4,
    );
    img.fill(canvas, color: img.ColorRgba8(15, 20, 24, 255));

    // Dimensions
    const topPhotoX = padding;
    const topPhotoY = padding;
    const topPhotoW = canvasWidth - (padding * 2);
    const topPhotoH = 640;

    const row2Y = topPhotoY + topPhotoH + padding;
    const row2W = (canvasWidth - (padding * 3)) ~/ 2;
    const row2H = 430;
    const photo2X = padding;
    const photo3X = photo2X + row2W + padding;

    // 3. Composite Photo 1 (Sholat Subuh - Top Hero)
    final topResized = _cropAndFit(img1, topPhotoW, topPhotoH);
    _drawPhotoWatermark(
      image: topResized,
      prayerTag: 'Sholat Subuh',
      timestamp: captures[0].timestamp,
      location: distProv,
      isHero: true,
    );
    img.compositeImage(canvas, topResized, dstX: topPhotoX, dstY: topPhotoY);

    // 4. Composite Photo 2 (Sholat Maghrib - Bottom Left)
    final photo2Resized = _cropAndFit(img2, row2W, row2H);
    _drawPhotoWatermark(
      image: photo2Resized,
      prayerTag: 'Sholat Maghrib',
      timestamp: captures[1].timestamp,
      location: distProv,
      isHero: false,
    );
    img.compositeImage(canvas, photo2Resized, dstX: photo2X, dstY: row2Y);

    // 5. Composite Photo 3 (Sholat Isya - Bottom Right)
    final photo3Resized = _cropAndFit(img3, row2W, row2H);
    _drawPhotoWatermark(
      image: photo3Resized,
      prayerTag: 'Sholat Isya',
      timestamp: captures[2].timestamp,
      location: distProv,
      isHero: false,
    );
    img.compositeImage(canvas, photo3Resized, dstX: photo3X, dstY: row2Y);

    // 6. Draw Bottom Information Card
    const infoCardY = row2Y + row2H + padding;
    const infoCardW = canvasWidth - (padding * 2);
    const infoCardH = canvasHeight - infoCardY - padding;

    // Card background
    img.fillRect(
      canvas,
      x1: padding,
      y1: infoCardY,
      x2: padding + infoCardW,
      y2: infoCardY + infoCardH,
      color: img.ColorRgba8(24, 32, 38, 255),
    );

    // Accent line (Emerald / Teal)
    img.fillRect(
      canvas,
      x1: padding,
      y1: infoCardY,
      x2: padding + 10,
      y2: infoCardY + infoCardH,
      color: img.ColorRgba8(13, 124, 102, 255),
    );

    // Bottom Card Typography
    const textStartX = padding + 28;
    int curY = infoCardY + 22;

    // Header
    img.drawString(
      canvas,
      'SHOLAT SIGMA • DOKUMENTASI SHOLAT 3 WAKTU',
      font: img.arial24,
      x: textStartX,
      y: curY,
      color: img.ColorRgba8(65, 179, 162, 255),
    );

    // Nama Siswa / Pelapor
    curY += 34;
    final cleanName = studentName.trim().isNotEmpty ? studentName.trim() : 'Siswa / Peserta';
    img.drawString(
      canvas,
      'Nama: $cleanName',
      font: img.arial48,
      x: textStartX,
      y: curY,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    // Waktu Sholat 3 Sesi
    curY += 52;
    final timeSubuh = TimeUtils.formatTime(captures[0].timestamp);
    final timeMaghrib = TimeUtils.formatTime(captures[1].timestamp);
    final timeIsya = TimeUtils.formatTime(captures[2].timestamp);
    final prayersSummary = 'Subuh: $timeSubuh WIB  |  Maghrib: $timeMaghrib WIB  |  Isya: $timeIsya WIB';
    img.drawString(
      canvas,
      prayersSummary,
      font: img.arial24,
      x: textStartX,
      y: curY,
      color: img.ColorRgba8(210, 235, 225, 255),
    );

    // Lokasi & Keterangan
    curY += 32;
    img.drawString(
      canvas,
      'Tempat: $locationName  |  Lat ${lat.toStringAsFixed(5)} Long ${lng.toStringAsFixed(5)}',
      font: img.arial24,
      x: textStartX,
      y: curY,
      color: img.ColorRgba8(170, 195, 200, 255),
    );

    if (description.trim().isNotEmpty && description.trim() != activityTitle) {
      curY += 30;
      img.drawString(
        canvas,
        'Catatan: ${description.trim()}',
        font: img.arial24,
        x: textStartX,
        y: curY,
        color: img.ColorRgba8(150, 175, 180, 255),
      );
    }

    // 7. Compress to high quality JPEG
    final jpegBytes = img.encodeJpg(canvas, quality: 90);

    // 8. On Web: return Data URL
    if (kIsWeb) {
      return 'data:image/jpeg;base64,${base64Encode(jpegBytes)}';
    }

    // 9. On Mobile/Desktop: Save to local directory
    final appDir = await getApplicationDocumentsDirectory();
    final collagesDir = Directory('${appDir.path}/collages');
    if (!collagesDir.existsSync()) {
      collagesDir.createSync(recursive: true);
    }

    final filename = 'sigma_geotag_${documentationTimestamp.millisecondsSinceEpoch}.jpg';
    final destinationFile = File('${collagesDir.path}/$filename');
    await destinationFile.writeAsBytes(jpegBytes);

    return destinationFile.path;
  }

  /// Draws clean, high-contrast watermark text on each photo:
  /// 1. Tanggal
  /// 2. Lokasi foto diambil
  /// 3. Jam foto diambil
  static void _drawPhotoWatermark({
    required img.Image image,
    required String prayerTag,
    required DateTime timestamp,
    required String location,
    required bool isHero,
  }) {
    final w = image.width;
    final h = image.height;

    // Dark semi-transparent gradient backdrop at the bottom
    final overlayH = isHero ? 165 : 135;
    final overlayY = h - overlayH;

    for (int y = overlayY; y < h; y++) {
      final alpha = ((y - overlayY) / overlayH * 210).clamp(90, 220).toInt();
      for (int x = 0; x < w; x++) {
        final origPixel = image.getPixel(x, y);
        final factor = alpha / 255.0;
        final r = (origPixel.r * (1 - factor)).round();
        final g = (origPixel.g * (1 - factor)).round();
        final b = (origPixel.b * (1 - factor)).round();
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    final dd = timestamp.day.toString().padLeft(2, '0');
    final mm = timestamp.month.toString().padLeft(2, '0');
    final yyyy = timestamp.year.toString().padLeft(4, '0');
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final min = timestamp.minute.toString().padLeft(2, '0');

    final dateStr = '$dd/$mm/$yyyy';
    final timeStr = '$hh:$min WIB';
    final locStr = location.trim().isNotEmpty ? location.trim() : 'Lokasi Terdeteksi';

    if (isHero) {
      // Emerald vertical accent bar
      const barX = 24;
      const barW = 6;
      final barY = overlayY + 18;
      final barH = overlayH - 36;
      img.fillRect(
        image,
        x1: barX,
        y1: barY,
        x2: barX + barW,
        y2: barY + barH,
        color: img.ColorRgba8(13, 124, 102, 255),
      );

      const textX = barX + barW + 18;
      int curY = overlayY + 20;

      // 1. Tanggal
      img.drawString(
        image,
        'Tanggal : $dateStr ($prayerTag)',
        font: img.arial24,
        x: textX,
        y: curY,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      // 2. Lokasi foto diambil
      curY += 38;
      img.drawString(
        image,
        'Lokasi  : ${_truncateText(locStr, 50)}',
        font: img.arial24,
        x: textX,
        y: curY,
        color: img.ColorRgba8(240, 240, 240, 255),
      );

      // 3. Jam foto diambil
      curY += 38;
      img.drawString(
        image,
        'Jam     : $timeStr',
        font: img.arial24,
        x: textX,
        y: curY,
        color: img.ColorRgba8(100, 220, 190, 255),
      );
    } else {
      // Emerald vertical accent bar for smaller row photos
      const barX = 14;
      const barW = 5;
      final barY = overlayY + 14;
      final barH = overlayH - 28;
      img.fillRect(
        image,
        x1: barX,
        y1: barY,
        x2: barX + barW,
        y2: barY + barH,
        color: img.ColorRgba8(13, 124, 102, 255),
      );

      const textX = barX + barW + 12;
      int curY = overlayY + 16;

      // 1. Tanggal
      img.drawString(
        image,
        'Tanggal : $dateStr ($prayerTag)',
        font: img.arial24,
        x: textX,
        y: curY,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      // 2. Lokasi foto diambil
      curY += 34;
      img.drawString(
        image,
        'Lokasi  : ${_truncateText(locStr, 26)}',
        font: img.arial24,
        x: textX,
        y: curY,
        color: img.ColorRgba8(240, 240, 240, 255),
      );

      // 3. Jam foto diambil
      curY += 34;
      img.drawString(
        image,
        'Jam     : $timeStr',
        font: img.arial24,
        x: textX,
        y: curY,
        color: img.ColorRgba8(100, 220, 190, 255),
      );
    }
  }

  static String _truncateText(String str, int maxLen) {
    if (str.length <= maxLen) return str;
    return '${str.substring(0, maxLen - 3)}...';
  }

  /// Safe image loader that decodes and handles EXIF orientation
  static Future<img.Image> _loadAndNormalize(
    String path,
    int maxWidth,
    int maxHeight,
  ) async {
    Uint8List bytes;
    if (path.startsWith('data:image')) {
      final commaIndex = path.indexOf(',');
      final base64Str = commaIndex != -1 ? path.substring(commaIndex + 1) : path;
      bytes = base64Decode(base64Str);
    } else if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) {
      final xFile = XFile(path);
      bytes = await xFile.readAsBytes();
    } else {
      bytes = await File(path).readAsBytes();
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Gagal membaca format gambar dari $path');
    }
    final oriented = img.bakeOrientation(decoded);
    return oriented;
  }

  /// Crops image to exact aspect ratio and scales smoothly to target size
  static img.Image _cropAndFit(img.Image src, int targetWidth, int targetHeight) {
    final targetAspect = targetWidth / targetHeight;
    final srcAspect = src.width / src.height;

    int cropX = 0;
    int cropY = 0;
    int cropW = src.width;
    int cropH = src.height;

    if (srcAspect > targetAspect) {
      cropW = (src.height * targetAspect).round();
      cropX = (src.width - cropW) ~/ 2;
    } else {
      cropH = (src.width / targetAspect).round();
      cropY = (src.height - cropH) ~/ 2;
    }

    final cropped = img.copyCrop(
      src,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    return img.copyResize(
      cropped,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );
  }
}
