# Project-specific ProGuard rules
# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Keep application class and custom views (adjust as needed)
-keep class com.kumarpay.rtpgame.** { *; }

# Keep plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
