import 'dart:convert';
import 'dart:io';

class DocumentationItem {
  final String id;
  final String title;
  final String studentName; // Nama Siswa / Pelapor
  final String description; // Keterangan / Catatan
  final DateTime timestamp; // Primary timestamp (Tanggal)
  final List<DateTime> photoTimestamps;
  final String locationName; // Tempat / Lokasi (e.g. Kecamatan Cibiru)
  final String districtProvince; // e.g. "Kecamatan Cibiru, Jawa Barat, Indonesia"
  final String fullAddress; // e.g. "Pasir Biru, Kec. Cibiru, Kota Bandung, Jawa Barat 40615, Indonesia"
  final double? latitude;
  final double? longitude;
  final String collageImagePath;
  final List<String> originalPhotoPaths;
  final DateTime createdAt;

  const DocumentationItem({
    required this.id,
    required this.title,
    this.studentName = '',
    required this.description,
    required this.timestamp,
    required this.photoTimestamps,
    required this.locationName,
    this.districtProvince = '',
    this.fullAddress = '',
    this.latitude,
    this.longitude,
    required this.collageImagePath,
    this.originalPhotoPaths = const [],
    required this.createdAt,
  });

  bool get collageExists => File(collageImagePath).existsSync();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'studentName': studentName,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'photoTimestamps': photoTimestamps.map((t) => t.toIso8601String()).toList(),
      'locationName': locationName,
      'districtProvince': districtProvince,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'collageImagePath': collageImagePath,
      'originalPhotoPaths': originalPhotoPaths,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DocumentationItem.fromMap(Map<String, dynamic> map) {
    return DocumentationItem(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Dokumentasi Sholat Subuh, Maghrib, Isya',
      studentName: map['studentName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      timestamp: DateTime.parse(map['timestamp'] as String),
      photoTimestamps: (map['photoTimestamps'] as List<dynamic>?)
              ?.map((t) => DateTime.parse(t as String))
              .toList() ??
          [],
      locationName: map['locationName'] as String? ?? 'Lokasi tidak tersedia',
      districtProvince: map['districtProvince'] as String? ?? '',
      fullAddress: map['fullAddress'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      collageImagePath: map['collageImagePath'] as String,
      originalPhotoPaths: (map['originalPhotoPaths'] as List<dynamic>?)
              ?.map((p) => p as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentationItem.fromJson(String source) =>
      DocumentationItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
