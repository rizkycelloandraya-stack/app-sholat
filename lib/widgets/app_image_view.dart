import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Cross-platform image widget that seamlessly renders:
/// - Base64 Data URLs (e.g. data:image/jpeg;base64,...)
/// - Web Blob URLs (blob:http...)
/// - Network URLs (http/https)
/// - Local device files on Android / iOS (File)
class AppImageView extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImageView({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildError();
    }

    // 1. Data URL (Base64)
    if (imagePath.startsWith('data:image')) {
      try {
        final commaIndex = imagePath.indexOf(',');
        final base64Str = commaIndex != -1 ? imagePath.substring(commaIndex + 1) : imagePath;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildError(),
        );
      } catch (_) {
        return _buildError();
      }
    }

    // 2. Web / Blob / Remote URL
    if (kIsWeb || imagePath.startsWith('http://') || imagePath.startsWith('https://') || imagePath.startsWith('blob:')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildError(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        },
      );
    }

    // 3. Native File (Android/iOS)
    final file = File(imagePath);
    if (!file.existsSync()) {
      return _buildError();
    }

    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildError(),
    );
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.black26,
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 28),
          ),
        );
  }
}
