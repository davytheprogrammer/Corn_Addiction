# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Prevent texture rendering issues
-keep class android.graphics.** { *; }
-keep class android.opengl.** { *; }
-dontwarn android.graphics.**
-dontwarn android.opengl.**

# Camera and image handling
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**