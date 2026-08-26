import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/app_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pengaturan'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // ================= PRAYER SECTION =================
              _buildSectionHeader('PENGINGAT & ALARM SHOLAT', isDark),
              Card(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Alarm Subuh',
                      'Bunyikan notifikasi waktu Subuh',
                      settings.alarmSubuh,
                      (val) => provider.updateSettings(
                        settings.copyWith(alarmSubuh: val),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Alarm Dzuhur',
                      'Bunyikan notifikasi waktu Dzuhur',
                      settings.alarmDzuhur,
                      (val) => provider.updateSettings(
                        settings.copyWith(alarmDzuhur: val),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Alarm Ashar',
                      'Bunyikan notifikasi waktu Ashar',
                      settings.alarmAshar,
                      (val) => provider.updateSettings(
                        settings.copyWith(alarmAshar: val),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Alarm Maghrib',
                      'Bunyikan notifikasi waktu Maghrib',
                      settings.alarmMaghrib,
                      (val) => provider.updateSettings(
                        settings.copyWith(alarmMaghrib: val),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Alarm Isya',
                      'Bunyikan notifikasi waktu Isya',
                      settings.alarmIsya,
                      (val) => provider.updateSettings(
                        settings.copyWith(alarmIsya: val),
                      ),
                    ),
                  ],
                ),
              ),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Waktu Pengingat Sholat'),
                      subtitle: Text(
                        settings.reminderMinutesBefore == 0
                            ? 'Tepat saat masuk waktu'
                            : '${settings.reminderMinutesBefore} menit sebelum waktu',
                      ),
                      trailing: DropdownButton<int>(
                        value: settings.reminderMinutesBefore,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Tepat waktu'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5 mnt sebelum'),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('10 mnt sebelum'),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text('15 mnt sebelum'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            provider.updateSettings(
                              settings.copyWith(reminderMinutesBefore: val),
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Suara Notifikasi',
                      'Aktifkan nada dering saat notifikasi masuk',
                      settings.soundEnabled,
                      (val) => provider.updateSettings(
                        settings.copyWith(soundEnabled: val),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Getaran',
                      'Getarkan perangkat saat notifikasi',
                      settings.vibrationEnabled,
                      (val) => provider.updateSettings(
                        settings.copyWith(vibrationEnabled: val),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CALCULATION METHOD =================
              _buildSectionHeader('METODE HISAB & FIQIH', isDark),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Metode Perhitungan'),
                      subtitle: Text(_getMethodDisplayName(settings.calculationMethod)),
                      trailing: DropdownButton<String>(
                        value: settings.calculationMethod,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'kemenag',
                            child: Text('Kemenag RI (Standar)'),
                          ),
                          DropdownMenuItem(
                            value: 'muslim_world_league',
                            child: Text('Muslim World League'),
                          ),
                          DropdownMenuItem(
                            value: 'egyptian',
                            child: Text('Egyptian General Auth'),
                          ),
                          DropdownMenuItem(
                            value: 'karachi',
                            child: Text('Univ. Karachi'),
                          ),
                          DropdownMenuItem(
                            value: 'umm_al_qura',
                            child: Text('Umm al-Qura'),
                          ),
                          DropdownMenuItem(
                            value: 'north_america',
                            child: Text('ISNA (North America)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            provider.updateSettings(
                              settings.copyWith(calculationMethod: val),
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Mazhab Perhitungan Ashar'),
                      subtitle: Text(
                        settings.madhhab == 'hanafi'
                            ? 'Hanafi (Bayangan 2x)'
                            : 'Syafi\'i / Standar (Bayangan 1x)',
                      ),
                      trailing: DropdownButton<String>(
                        value: settings.madhhab,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'shafii',
                            child: Text('Syafi\'i / Standar'),
                          ),
                          DropdownMenuItem(
                            value: 'hanafi',
                            child: Text('Hanafi'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            provider.updateSettings(
                              settings.copyWith(madhhab: val),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= DOCUMENTATION SECTION =================
              _buildSectionHeader('DOKUMENTASI 3-FOTO', isDark),
              Card(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Mode Otomatis 3 Foto',
                      'Langsung proses kolase otomatis setelah foto ke-3',
                      settings.auto3PhotoMode,
                      (val) => provider.updateSettings(
                        settings.copyWith(auto3PhotoMode: val),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Bagikan Otomatis ke WhatsApp',
                      'Buka lembar berbagi sistem langsung setelah kolase siap',
                      settings.autoWhatsAppShare,
                      (val) => provider.updateSettings(
                        settings.copyWith(autoWhatsAppShare: val),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      'Simpan Foto Asli',
                      'Simpan 3 file foto mentah selain kolase jadi',
                      settings.saveOriginalPhotos,
                      (val) => provider.updateSettings(
                        settings.copyWith(saveOriginalPhotos: val),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= LOCATION SECTION =================
              _buildSectionHeader('LOKASI GPS', isDark),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFF0D7C66),
                  ),
                  title: const Text('Lokasi Saat Ini'),
                  subtitle: Text(
                    '${provider.locationName}\nLat: ${provider.latitude.toStringAsFixed(4)}, Lng: ${provider.longitude.toStringAsFixed(4)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: provider.isLocationRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    onPressed: () => provider.refreshLocation(),
                  ),
                ),
              ),

              // ================= APPEARANCE SECTION =================
              _buildSectionHeader('TAMPILAN', isDark),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.palette_outlined,
                    color: Color(0xFF0D7C66),
                  ),
                  title: const Text('Tema Aplikasi'),
                  subtitle: Text(_getThemeDisplayName(settings.themeSetting)),
                  trailing: DropdownButton<AppThemeSetting>(
                    value: settings.themeSetting,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: AppThemeSetting.system,
                        child: Text('Ikuti Sistem'),
                      ),
                      DropdownMenuItem(
                        value: AppThemeSetting.light,
                        child: Text('Mode Terang'),
                      ),
                      DropdownMenuItem(
                        value: AppThemeSetting.dark,
                        child: Text('Mode Gelap'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        provider.updateSettings(
                          settings.copyWith(themeSetting: val),
                        );
                      }
                    },
                  ),
                ),
              ),

              // ================= ABOUT SECTION =================
              _buildSectionHeader('TENTANG', isDark),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0D7C66),
                  ),
                  title: const Text('Tentang Sholat Sigma'),
                  subtitle: const Text('Versi 1.0.0 (Produksi)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: isDark ? Colors.white60 : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeThumbColor: const Color(0xFF0D7C66),
      onChanged: onChanged,
    );
  }

  String _getMethodDisplayName(String code) {
    switch (code) {
      case 'kemenag':
        return 'Kemenag RI (Standar)';
      case 'muslim_world_league':
        return 'Muslim World League';
      case 'egyptian':
        return 'Egyptian General Authority';
      case 'karachi':
        return 'Univ. of Islamic Sciences, Karachi';
      case 'umm_al_qura':
        return 'Umm al-Qura, Makkah';
      case 'north_america':
        return 'ISNA (North America)';
      default:
        return 'Kemenag RI (Standar)';
    }
  }

  String _getThemeDisplayName(AppThemeSetting theme) {
    switch (theme) {
      case AppThemeSetting.system:
        return 'Ikuti Sistem';
      case AppThemeSetting.light:
        return 'Mode Terang';
      case AppThemeSetting.dark:
        return 'Mode Gelap';
    }
  }
}
