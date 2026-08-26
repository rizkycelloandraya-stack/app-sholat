import 'package:flutter/material.dart';

class DocumentationActionBar extends StatelessWidget {
  final VoidCallback onDokumentasiTap;
  final VoidCallback onRiwayatTap;
  final VoidCallback onPengaturanTap;

  const DocumentationActionBar({
    super.key,
    required this.onDokumentasiTap,
    required this.onRiwayatTap,
    required this.onPengaturanTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large Primary "DOKUMENTASI" button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onDokumentasiTap,
                icon: const Icon(Icons.camera_alt_rounded, size: 24),
                label: const Text(
                  'DOKUMENTASI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7C66),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFF0D7C66).withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Buttons: "RIWAYAT" and "PENGATURAN"
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRiwayatTap,
                    icon: const Icon(Icons.history_rounded, size: 20),
                    label: const Text('RIWAYAT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? const Color(0xFF41B3A2)
                          : const Color(0xFF0D7C66),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF334B44)
                            : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPengaturanTap,
                    icon: const Icon(Icons.settings_rounded, size: 20),
                    label: const Text('PENGATURAN'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? const Color(0xFF41B3A2)
                          : const Color(0xFF0D7C66),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF334B44)
                            : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
