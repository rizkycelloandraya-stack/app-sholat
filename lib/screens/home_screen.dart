import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/countdown_card.dart';
import '../widgets/prayer_card.dart';
import '../widgets/documentation_action_bar.dart';
import '../widgets/particle_3d_background.dart';
import 'documentation_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final schedule = provider.prayerSchedule;

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF0D9488),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.45),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'SHOLAT SIGMA 3D',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    fontSize: 19,
                    shadows: [
                      Shadow(
                        color: Color(0x662DD4BF),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Pengaturan',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Particle3DBackground(
            particleCount: 85,
            child: SafeArea(
              bottom: false,
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2DD4BF),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF10B981),
                      onRefresh: () => provider.refreshLocation(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Next prayer 3D holographic countdown hero
                          SliverToBoxAdapter(
                            child: CountdownCard(
                              schedule: schedule,
                              locationName: provider.locationName,
                              isLocationRefreshing:
                                  provider.isLocationRefreshing,
                              onRefreshLocation: () =>
                                  provider.refreshLocation(),
                            ),
                          ),

                          // Section Title: Prayer Schedule
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'JADWAL SHOLAT HARI INI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: isDark
                                          ? const Color(0xFF99F6E4)
                                          : const Color(0xFF0F766E),
                                    ),
                                  ),
                                  if (schedule != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2DD4BF)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF2DD4BF)
                                              .withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Text(
                                        'ZONA WIB',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? const Color(0xFF5EEAD4)
                                              : const Color(0xFF0D7C66),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // 5 Daily Prayer 3D Cards
                          if (schedule != null)
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final prayer = schedule.prayers[index];
                                  return PrayerCard(prayer: prayer);
                                },
                                childCount: schedule.prayers.length,
                              ),
                            )
                          else
                            const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text('Memuat jadwal sholat...'),
                                ),
                              ),
                            ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 155),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Made by Cello Andraya Rizky',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF5EEAD4)
                                            .withValues(alpha: 0.55)
                                        : const Color(0xFF64748B),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          bottomNavigationBar: DocumentationActionBar(
            onDokumentasiTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DocumentationScreen(),
                ),
              );
            },
            onRiwayatTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
            onPengaturanTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
