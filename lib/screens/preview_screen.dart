import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/documentation_item.dart';
import '../providers/app_provider.dart';
import '../services/sharing_service.dart';
import '../utils/time_utils.dart';
import '../widgets/collage_preview_widget.dart';

class PreviewScreen extends StatefulWidget {
  final DocumentationItem item;

  const PreviewScreen({
    super.key,
    required this.item,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DocumentationItem _currentItem;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _nameController = TextEditingController(text: widget.item.studentName);
    _titleController = TextEditingController(text: widget.item.title);
    _descController = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updated = DocumentationItem(
      id: _currentItem.id,
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : _currentItem.title,
      studentName: _nameController.text.trim(),
      description: _descController.text.trim(),
      timestamp: _currentItem.timestamp,
      photoTimestamps: _currentItem.photoTimestamps,
      locationName: _currentItem.locationName,
      districtProvince: _currentItem.districtProvince,
      fullAddress: _currentItem.fullAddress,
      latitude: _currentItem.latitude,
      longitude: _currentItem.longitude,
      collageImagePath: _currentItem.collageImagePath,
      originalPhotoPaths: _currentItem.originalPhotoPaths,
      createdAt: _currentItem.createdAt,
    );

    setState(() => _currentItem = updated);
    await context.read<AppProvider>().updateHistoryItem(updated);
  }

  Future<void> _share() async {
    await _saveChanges();
    setState(() => _isSharing = true);
    final success = await SharingService.shareDocumentation(_currentItem);
    setState(() => _isSharing = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka lembar berbagi.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dateStr = TimeUtils.formatDateIndonesian(_currentItem.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Dokumentasi 3 Sholat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan ke WhatsApp',
            onPressed: _isSharing ? null : _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generated Collage Preview
            CollagePreviewWidget(
              imagePath: _currentItem.collageImagePath,
            ),
            const SizedBox(height: 16),

            // Metadata card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2422) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A3633)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  if (_currentItem.studentName.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 18, color: Color(0xFF0D7C66)),
                        const SizedBox(width: 8),
                        Text(
                          'Nama: ${_currentItem.studentName}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: Color(0xFF0D7C66)),
                      const SizedBox(width: 8),
                      Text(
                        'Tanggal: $dateStr',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 16, color: Color(0xFF0D7C66)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentItem.locationName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (_currentItem.photoTimestamps.isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPrayerTimeChip('Subuh', _currentItem.photoTimestamps.isNotEmpty ? _currentItem.photoTimestamps[0] : null),
                        _buildPrayerTimeChip('Maghrib', _currentItem.photoTimestamps.length > 1 ? _currentItem.photoTimestamps[1] : null),
                        _buildPrayerTimeChip('Isya', _currentItem.photoTimestamps.length > 2 ? _currentItem.photoTimestamps[2] : null),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fast Edit Section
            Text(
              'EDIT IDENTITAS & KETERANGAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),

            // Name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Siswa / Pelapor',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (_) => _saveChanges(),
            ),
            const SizedBox(height: 12),

            // Title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Dokumentasi',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              onChanged: (_) => _saveChanges(),
            ),
            const SizedBox(height: 12),

            // Description input
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Keterangan Tambahan',
                prefixIcon: Icon(Icons.notes_rounded),
                hintText: 'Contoh: Sholat berjamaah tepat waktu.',
              ),
              onChanged: (_) => _saveChanges(),
            ),
            const SizedBox(height: 24),

            // Primary Share Button
            SizedBox(
              width: double.infinity,
              height: 54,
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
            const SizedBox(height: 10),

            // Return to Home
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('SELESAI & KEMBALI KE BERANDA'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeChip(String prayer, DateTime? time) {
    return Column(
      children: [
        Text(
          prayer,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0D7C66)),
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
