import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Sholat Sigma'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // App Icon & Title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D7C66),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D7C66).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'SHOLAT SIGMA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),

            const Text(
              'Versi 1.0.0 (Produksi)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Card: App Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.class_rounded,
                            color: Color(0xFF0D7C66), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tujuan Aplikasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sholat Sigma adalah asisten pengingat waktu sholat dan dokumentasi kegiatan kelas cepat yang dirancang khusus untuk kelompok kelas (±18 siswa).',
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Aplikasi ini secara instan mengambil tepat 3 foto, mendeteksi waktu dan lokasi, mencocokkan jadwal sholat hari ini, membuat kolase beresolusi tinggi, dan langsung membuka lembar berbagi WhatsApp.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Card: Privacy & Offline Guarantee
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security_rounded,
                            color: Color(0xFF0D7C66), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Privasi & Keamanan Lokal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '• 100% Offline: Tidak ada data foto, koordinat GPS, atau nama kegiatan yang dikirim ke server luar/cloud.',
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Tanpa Akun: Tidak memerlukan registrasi, login, ataupun database pihak ketiga.',
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Penyimpanan Aman: Semua riwayat dan kolase dokumentasi tersimpan di media privat perangkat pengguna.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Card: Developer Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    const Icon(Icons.code_rounded,
                        color: Color(0xFF0D7C66), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pengembang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cello Andraya Rizky',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
