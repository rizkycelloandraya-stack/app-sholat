# Flutter Wrapper Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Suppress Play Core / Deferred components warnings for Flutter
-dontwarn com.google.android.play.core.**

# Keep Adhan and Date classes
-dontwarn java.time.**
-dontwarn org.threeten.bp.**

# Local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
