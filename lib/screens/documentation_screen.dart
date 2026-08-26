import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/documentation_provider.dart';
import '../models/photo_capture.dart';
import '../utils/time_utils.dart';
import 'preview_screen.dart';

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      final docProvider = context.read<DocumentationProvider>();
      docProvider.reset();
      docProvider.init(appProvider.locationName).then((_) {
        if (mounted) {
          _nameController.text = docProvider.studentName;
          _locationController.text = docProvider.locationName.isNotEmpty
              ? docProvider.locationName
              : appProvider.locationName;
          _notesController.text = docProvider.editingDescription;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotoForSlot(int slotIndex, ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (picked != null && mounted) {
        final docProvider = context.read<DocumentationProvider>();
        docProvider.setPhotoForSlot(
          slotIndex,
          picked.path,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _processAndNavigate() async {
    final appProvider = context.read<AppProvider>();
    final docProvider = context.read<DocumentationProvider>();

    if (!docProvider.isAllSlotsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua foto: Sholat Subuh, Maghrib, dan Isya!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Update form values
    docProvider.setStudentName(_nameController.text.trim());
    docProvider.setLocationName(_locationController.text.trim());
    docProvider.setEditingDescription(_notesController.text.trim());

    final docItem = await docProvider.processAndGenerateCollage(
      prayerSchedule: appProvider.prayerSchedule,
      locationName: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : appProvider.locationName,
      latitude: appProvider.latitude,
      longitude: appProvider.longitude,
      settings: appProvider.settings,
      customStudentName: _nameController.text.trim(),
      customDescription: _notesController.text.trim(),
    );

    if (docItem != null && mounted) {
      await appProvider.refreshHistory();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PreviewScreen(item: docItem),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<DocumentationProvider>(
      builder: (context, docProvider, child) {
        final currentCount = docProvider.currentCount;
        final isProcessing = docProvider.state == DocWorkflowState.processing;
        final isReady = docProvider.isAllSlotsFilled;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'DOKUMENTASI 3 SHOLAT',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isReady ? const Color(0xFF0D7C66) : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentCount / 3 Foto',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information / Form Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2927) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A3A36)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D7C66).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.badge_rounded,
                                  color: Color(0xFF0D7C66),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'IDENTITAS & KETERANGAN',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Nama Siswa / Pelapor
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap Siswa / Pelapor *',
                              hintText: 'Contoh: Ahmad Fauzan (Kelas 7A)',
                              prefixIcon: const Icon(Icons.person_rounded, size: 20),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) => docProvider.setStudentName(val),
                          ),
                          const SizedBox(height: 12),

                          // Tempat / Lokasi
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Tempat / Lokasi Sholat *',
                              hintText: 'Contoh: Masjid Sekolah / Musholla Al-Ikhlas',
                              prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) => docProvider.setLocationName(val),
                          ),
                          const SizedBox(height: 12),

                          // Keterangan / Catatan
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Keterangan / Catatan Kegiatan (Opsional)',
                              hintText: 'Contoh: Sholat berjamaah bersama guru dan teman sekelas.',
                              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) => docProvider.setEditingDescription(val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title Section: 3 Prayer Slots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'UNGGAH 3 FOTO SHOLAT WAJIB',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          ),
                        ),
                        const Text(
                          'Subuh • Maghrib • Isya',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D7C66),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Slot 1: Sholat Subuh
                    _buildPrayerSlotCard(
                      slotIndex: 0,
                      prayerName: '1. SHOLAT SUBUH',
                      prayerDesc: 'Foto dokumentasi ibadah sholat Subuh',
                      icon: Icons.wb_twilight_rounded,
                      accentColor: const Color(0xFF2563EB),
                      photo: docProvider.subuhPhoto,
                      isDark: isDark,
                      onCamera: () => _pickPhotoForSlot(0, ImageSource.camera),
                      onGallery: () => _pickPhotoForSlot(0, ImageSource.gallery),
                      onDelete: () => docProvider.removePhotoForSlot(0),
                    ),

                    const SizedBox(height: 12),

                    // Slot 2: Sholat Maghrib
                    _buildPrayerSlotCard(
                      slotIndex: 1,
                      prayerName: '2. SHOLAT MAGHRIB',
                      prayerDesc: 'Foto dokumentasi ibadah sholat Maghrib',
                      icon: Icons.wb_sunny_outlined,
                      accentColor: const Color(0xFFD97706),
                      photo: docProvider.maghribPhoto,
                      isDark: isDark,
                      onCamera: () => _pickPhotoForSlot(1, ImageSource.camera),
                      onGallery: () => _pickPhotoForSlot(1, ImageSource.gallery),
                      onDelete: () => docProvider.removePhotoForSlot(1),
                    ),

                    const SizedBox(height: 12),

                    // Slot 3: Sholat Isya
                    _buildPrayerSlotCard(
                      slotIndex: 2,
                      prayerName: '3. SHOLAT ISYA',
                      prayerDesc: 'Foto dokumentasi ibadah sholat Isya',
                      icon: Icons.nightlight_round,
                      accentColor: const Color(0xFF7C3AED),
                      photo: docProvider.isyaPhoto,
                      isDark: isDark,
                      onCamera: () => _pickPhotoForSlot(2, ImageSource.camera),
                      onGallery: () => _pickPhotoForSlot(2, ImageSource.gallery),
                      onDelete: () => docProvider.removePhotoForSlot(2),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Bottom Sticky Generate Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161F1E) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF2A3633) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isReady && !isProcessing ? _processAndNavigate : null,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        isReady
                            ? 'BUAT KOLASE DOKUMENTASI (3 SHOLAT)'
                            : 'LENGKAPI 3 FOTO ($currentCount/3 TERISI)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D7C66),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangle64Border(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ),

              // Processing Overlay
              if (isProcessing)
                Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF41B3A2),
                          strokeWidth: 3.5,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Menyusun Kolase Sholat 3 Waktu...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Menempel stempel waktu, lokasi & nama siswa',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerSlotCard({
    required int slotIndex,
    required String prayerName,
    required String prayerDesc,
    required IconData icon,
    required Color accentColor,
    required PhotoCapture? photo,
    required bool isDark,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onDelete,
  }) {
    final hasPhoto = photo != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2927) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPhoto
              ? const Color(0xFF0D7C66)
              : (isDark ? const Color(0xFF2A3A36) : const Color(0xFFE2E8F0)),
          width: hasPhoto ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Photo Thumbnail or Placeholder Icon
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: hasPhoto
                  ? Colors.black
                  : accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPhoto
                    ? const Color(0xFF0D7C66)
                    : accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      File(photo.filePath),
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    icon,
                    color: accentColor,
                    size: 36,
                  ),
          ),
          const SizedBox(width: 14),

          // Content and Action Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prayerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (hasPhoto)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D7C66).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF0D7C66), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Siap',
                              style: TextStyle(
                                color: Color(0xFF0D7C66),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hasPhoto
                      ? 'Waktu: ${TimeUtils.formatTime(photo.timestamp)} WIB (${TimeUtils.formatDateIndonesian(photo.timestamp)})'
                      : prayerDesc,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasPhoto
                        ? (isDark ? Colors.white70 : Colors.black87)
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),

                // Buttons
                if (!hasPhoto)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCamera,
                          icon: const Icon(Icons.camera_alt_rounded, size: 16),
                          label: const Text('Kamera', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onGallery,
                          icon: const Icon(Icons.photo_library_rounded, size: 16),
                          label: const Text('Galeri', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onCamera,
                        icon: const Icon(Icons.refresh_rounded, size: 15),
                        label: const Text('Ganti', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        tooltip: 'Hapus foto ini',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedRectangle64Border extends RoundedRectangleBorder {
  const RoundedRectangle64Border({super.borderRadius});
}
