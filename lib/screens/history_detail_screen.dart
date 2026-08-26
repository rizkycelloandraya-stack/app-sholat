import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/documentation_item.dart';
import '../providers/app_provider.dart';
import '../services/sharing_service.dart';
import '../utils/time_utils.dart';
import '../widgets/collage_preview_widget.dart';
import '../widgets/confirm_delete_dialog.dart';

class HistoryDetailScreen extends StatefulWidget {
  final DocumentationItem item;

  const HistoryDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  bool _isSharing = false;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    await SharingService.shareDocumentation(widget.item);
    setState(() => _isSharing = false);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        onConfirm: () async {
          await context
              .read<AppProvider>()
              .deleteHistoryItem(widget.item.id);
          if (mounted) {
            Navigator.of(context).pop(); // Exit detail screen
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = widget.item;

    final dateStr = TimeUtils.formatDateIndonesian(item.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan',
            onPressed: _isSharing ? null : _share,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Hapus',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Collage Viewer
            CollagePreviewWidget(
              imagePath: item.collageImagePath,
              onTap: () {
                // Open full-screen viewer if tapped
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        iconTheme: const IconThemeData(color: Colors.white),
                      ),
                      body: Center(
                        child: InteractiveViewer(
                          child: Image.file(File(item.collageImagePath)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Metadata card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2422) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A3633)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (item.studentName.isNotEmpty) ...[
                    _buildMetaRow(
                      Icons.person_rounded,
                      'Nama Siswa / Pelapor',
                      item.studentName,
                    ),
                    const SizedBox(height: 10),
                  ],

                  _buildMetaRow(
                    Icons.calendar_today_rounded,
                    'Tanggal',
                    dateStr,
                  ),
                  const SizedBox(height: 10),

                  _buildMetaRow(
                    Icons.location_on_rounded,
                    'Tempat / Lokasi',
                    item.locationName,
                  ),
                  if (item.fullAddress.isNotEmpty && item.fullAddress != item.locationName) ...[
                    const SizedBox(height: 10),
                    _buildMetaRow(
                      Icons.map_outlined,
                      'Alamat Lengkap',
                      item.fullAddress,
                    ),
                  ],
                  if (item.latitude != null && item.longitude != null) ...[
                    const SizedBox(height: 10),
                    _buildMetaRow(
                      Icons.pin_drop_rounded,
                      'Koordinat GPS',
                      'Lat ${item.latitude!.toStringAsFixed(6)} Long ${item.longitude!.toStringAsFixed(6)}',
                    ),
                  ],

                  if (item.photoTimestamps.isNotEmpty) ...[
                    const Divider(height: 20),
                    const Text(
                      'Waktu Foto Sholat:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPrayerTimeChip('1. Subuh', item.photoTimestamps.isNotEmpty ? item.photoTimestamps[0] : null),
                        _buildPrayerTimeChip('2. Maghrib', item.photoTimestamps.length > 1 ? item.photoTimestamps[1] : null),
                        _buildPrayerTimeChip('3. Isya', item.photoTimestamps.length > 2 ? item.photoTimestamps[2] : null),
                      ],
                    ),
                  ],

                  if (item.description.isNotEmpty &&
                      item.description != item.title) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Keterangan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share Action
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSharing ? null : _share,
                icon: const Icon(Icons.share_rounded),
                label: Text(
                  _isSharing ? 'Membuka WhatsApp...' : 'BAGIKAN KE WHATSAPP',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Delete Action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                label: const Text(
                  'HAPUS DOKUMENTASI',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D7C66)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimeChip(String prayer, DateTime? time) {
    return Column(
      children: [
        Text(
          prayer,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0D7C66)),
        ),
        const SizedBox(height: 2),
        Text(
          time != null ? '${TimeUtils.formatTime(time)} WIB' : '-',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
