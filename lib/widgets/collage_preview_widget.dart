import 'dart:io';
import 'package:flutter/material.dart';

class CollagePreviewWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const CollagePreviewWidget({
    super.key,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Gambar tidak ditemukan',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 300,
              color: Colors.grey.shade800,
              child: const Center(
                child: Icon(Icons.broken_image_rounded,
                    color: Colors.white54, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
