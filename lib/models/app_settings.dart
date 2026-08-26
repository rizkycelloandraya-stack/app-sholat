import 'dart:convert';
import 'package:flutter/material.dart';

enum AppThemeSetting {
  system,
  light,
  dark,
}

class AppSettings {
  final bool alarmSubuh;
  final bool alarmDzuhur;
  final bool alarmAshar;
  final bool alarmMaghrib;
  final bool alarmIsya;
  final int reminderMinutesBefore; // 0 = at prayer time, 5, 10, 15
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String calculationMethod; // 'kemenag', 'muslim_world_league', 'egyptian', 'karachi', 'umm_al_qura', 'north_america'
  final String madhhab; // 'shafii', 'hanafi'
  final bool auto3PhotoMode; // true: auto-generate after 3 photos, false: review step
  final bool autoWhatsAppShare; // true: trigger share sheet automatically
  final bool saveOriginalPhotos; // true: keep 3 original photo files
  final AppThemeSetting themeSetting;

  const AppSettings({
    this.alarmSubuh = true,
    this.alarmDzuhur = true,
    this.alarmAshar = true,
    this.alarmMaghrib = true,
    this.alarmIsya = true,
    this.reminderMinutesBefore = 0,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.calculationMethod = 'kemenag',
    this.madhhab = 'shafii',
    this.auto3PhotoMode = true,
    this.autoWhatsAppShare = true,
    this.saveOriginalPhotos = false,
    this.themeSetting = AppThemeSetting.system,
  });

  ThemeMode get themeMode {
    switch (themeSetting) {
      case AppThemeSetting.light:
        return ThemeMode.light;
      case AppThemeSetting.dark:
        return ThemeMode.dark;
      case AppThemeSetting.system:
        return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    bool? alarmSubuh,
    bool? alarmDzuhur,
    bool? alarmAshar,
    bool? alarmMaghrib,
    bool? alarmIsya,
    int? reminderMinutesBefore,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? calculationMethod,
    String? madhhab,
    bool? auto3PhotoMode,
    bool? autoWhatsAppShare,
    bool? saveOriginalPhotos,
    AppThemeSetting? themeSetting,
  }) {
    return AppSettings(
      alarmSubuh: alarmSubuh ?? this.alarmSubuh,
      alarmDzuhur: alarmDzuhur ?? this.alarmDzuhur,
      alarmAshar: alarmAshar ?? this.alarmAshar,
      alarmMaghrib: alarmMaghrib ?? this.alarmMaghrib,
      alarmIsya: alarmIsya ?? this.alarmIsya,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhhab: madhhab ?? this.madhhab,
      auto3PhotoMode: auto3PhotoMode ?? this.auto3PhotoMode,
      autoWhatsAppShare: autoWhatsAppShare ?? this.autoWhatsAppShare,
      saveOriginalPhotos: saveOriginalPhotos ?? this.saveOriginalPhotos,
      themeSetting: themeSetting ?? this.themeSetting,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alarmSubuh': alarmSubuh,
      'alarmDzuhur': alarmDzuhur,
      'alarmAshar': alarmAshar,
      'alarmMaghrib': alarmMaghrib,
      'alarmIsya': alarmIsya,
      'reminderMinutesBefore': reminderMinutesBefore,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'calculationMethod': calculationMethod,
      'madhhab': madhhab,
      'auto3PhotoMode': auto3PhotoMode,
      'autoWhatsAppShare': autoWhatsAppShare,
      'saveOriginalPhotos': saveOriginalPhotos,
      'themeSetting': themeSetting.index,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      alarmSubuh: map['alarmSubuh'] as bool? ?? true,
      alarmDzuhur: map['alarmDzuhur'] as bool? ?? true,
      alarmAshar: map['alarmAshar'] as bool? ?? true,
      alarmMaghrib: map['alarmMaghrib'] as bool? ?? true,
      alarmIsya: map['alarmIsya'] as bool? ?? true,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int? ?? 0,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      calculationMethod: map['calculationMethod'] as String? ?? 'kemenag',
      madhhab: map['madhhab'] as String? ?? 'shafii',
      auto3PhotoMode: map['auto3PhotoMode'] as bool? ?? true,
      autoWhatsAppShare: map['autoWhatsAppShare'] as bool? ?? true,
      saveOriginalPhotos: map['saveOriginalPhotos'] as bool? ?? false,
      themeSetting: AppThemeSetting.values[
          (map['themeSetting'] as int?)?.clamp(0, AppThemeSetting.values.length - 1) ?? 0],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) =>
      AppSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
