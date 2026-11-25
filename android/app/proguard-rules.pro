# Aturan ProGuard / R8 untuk aplikasi Funda (Flutter + Drift/SQLite + Notifikasi Lokal)

# Flutter wrapper & embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.embedding.engine.mutatorsstack.** { *; }
-keep class io.flutter.embedding.engine.renderer.** { *; }
-dontwarn io.flutter.embedding.**

# SQLite / sqlite3_flutter_libs / JNA
-keep class org.sqlite.** { *; }
-keep class com.sun.jna.** { *; }
-keepclassmembers class * extends com.sun.jna.** { *; }
-dontwarn java.awt.**
-dontwarn com.sun.jna.**

# flutter_local_notifications & GSON TypeToken
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.TypeAdapter
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Flutter Deferred / SplitCompat / Play Core optional refs
-dontwarn com.google.android.play.core.**
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
