# Flutter & Engine classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep all Flutter plugin classes
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep Flutter plugin implementations
-if class * implements io.flutter.embedding.engine.plugins.FlutterPlugin
-keep public class <1> { *; }

# Sqflite / SQLite
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**
-keep class io.flutter.plugins.sqflite.** { *; }
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
-keep class androidx.sqlite.** { *; }
-dontwarn org.sqlite.**
-dontwarn org.sqlite.database.**
-dontwarn androidx.sqlite.**

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# Google Mobile Ads / Play Services
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.internal.measurement.** { *; }
-keep class com.google.ads.** { *; }
-keep class io.flutter.plugins.googlemobileads.** { *; }
-keep public class com.google.android.gms.ads.** { public *; }
-keep public class com.google.ads.** { public *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.ads.**
-dontwarn io.flutter.plugins.googlemobileads.**

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# AndroidX & Lifecycle
-keep class androidx.lifecycle.** { *; }
-keep class androidx.core.** { *; }
-dontwarn androidx.lifecycle.**
-dontwarn androidx.core.**

# Keep attributes & annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable
