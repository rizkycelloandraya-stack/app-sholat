import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/time_utils.dart';
import '../widgets/app_image_view.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/particle_3d_background.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final history = provider.history;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Dokumentasi'),
            actions: [
              if (history.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Hapus Semua Riwayat & Bersihkan Penyimpanan',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ConfirmDeleteDialog(
                        title: 'Hapus Semua Foto & Riwayat?',
                        content:
                            'Semua kolase dan file foto tersimpan akan dihapus permanen untuk menghemat ruang penyimpanan.',
                        onConfirm: () async {
                          await provider.clearAllHistory();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Semua foto & riwayat berhasil dihapus. Penyimpanan telah dibersihkan!'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Particle3DBackground(
            particleCount: 65,
            child: history.isEmpty
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Riwayat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ambil 3 foto kegiatan sholat untuk membuat kolase dokumentasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final dateStr =
                        TimeUtils.formatDateIndonesian(item.timestamp);
                    final timeStr = TimeUtils.formatTime(item.timestamp);

                    return Glass3DCard(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      borderRadius: 20,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                HistoryDetailScreen(item: item),
                          ),
                        );
                      },
                      child: Row(
                            children: [
                              // Collage Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 72,
                                  height: 96,
                                  color: Colors.black12,
                                  child: AppImageView(
                                    imagePath: item.collageImagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Metadata
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 13,
                                          color: Color(0xFF0D7C66),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$dateStr • $timeStr WIB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white70
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 13,
                                          color: Color(0xFF0D7C66),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.locationName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white60
                                                  : const Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Direct Delete Photo button + Trailing arrow
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                tooltip: 'Hapus Foto Ini',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => ConfirmDeleteDialog(
                                      onConfirm: () async {
                                        await provider.deleteHistoryItem(item.id);
                                      },
                                    ),
                                  );
                                },
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF5EEAD4),
                              ),
                            ],
                          ),
                    );
                  },
                ),
          ),
        );
      },
    );
  }
}
