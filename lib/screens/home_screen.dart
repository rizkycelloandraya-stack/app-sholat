import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/countdown_card.dart';
import '../widgets/prayer_card.dart';
import '../widgets/documentation_action_bar.dart';
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
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D7C66),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'SHOLAT SIGMA',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 20,
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
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D7C66),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF0D7C66),
                  onRefresh: () => provider.refreshLocation(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Next prayer countdown hero
                      SliverToBoxAdapter(
                        child: CountdownCard(
                          schedule: schedule,
                          locationName: provider.locationName,
                          isLocationRefreshing: provider.isLocationRefreshing,
                          onRefreshLocation: () =>
                              provider.refreshLocation(),
                        ),
                      ),

                      // Section Title: Prayer Schedule
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'JADWAL SHOLAT HARI INI',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: isDark
                                      ? Colors.white60
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              if (schedule != null)
                                Text(
                                  'WIB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF41B3A2)
                                        : const Color(0xFF0D7C66),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // 5 Daily Prayer Cards
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
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Made by Cello Andraya Rizky',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
