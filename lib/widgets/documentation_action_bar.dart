import 'dart:ui';
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF0E2422).withValues(alpha: 0.85),
                      const Color(0xFF061113).withValues(alpha: 0.94),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.88),
                      const Color(0xFFECFDF5).withValues(alpha: 0.95),
                    ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: const Color(0xFF2DD4BF)
                    .withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981)
                    .withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Large 3D Glowing Primary "DOKUMENTASI" button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF0D9488),
                        Color(0xFF059669),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onDokumentasiTap,
                    icon: const Icon(Icons.camera_alt_rounded, size: 24),
                    label: const Text(
                      'DOKUMENTASI 3 SHOLAT',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary 3D Glass Buttons: "RIWAYAT" and "PENGATURAN"
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRiwayatTap,
                        icon: const Icon(Icons.history_rounded, size: 20),
                        label: const Text('RIWAYAT'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFF5EEAD4)
                              : const Color(0xFF0D7C66),
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.6),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF2DD4BF).withValues(alpha: 0.35)
                                : const Color(0xFF10B981).withValues(alpha: 0.35),
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
                              ? const Color(0xFF5EEAD4)
                              : const Color(0xFF0D7C66),
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.6),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF2DD4BF).withValues(alpha: 0.35)
                                : const Color(0xFF10B981).withValues(alpha: 0.35),
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
        ),
      ),
    );
  }
}
