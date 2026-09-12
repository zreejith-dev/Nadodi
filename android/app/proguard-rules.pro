# Flutter-specific R8/ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase
-dontwarn io.supabase.flutter.**
-keep class io.supabase.flutter.** { *; }

# Google Play Core (for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Credential Manager (Google Play 2027 Zero-Tap)
-dontwarn androidx.credentials.**
-keep class androidx.credentials.** { *; }
-dontwarn com.google.android.gms.auth.**
-keep class com.google.android.gms.auth.** { *; }

# Cached Network Image
-dontwarn com.github.chrisbanes.photoview.**
-keep class com.github.chrisbanes.photoview.** { *; }
-dontwarn com.bumptech.glide.**
-keep class com.bumptech.glide.** { *; }

# Flutter Map
-dontwarn io.flutter.plugins.flutter_map.**
-keep class io.flutter.plugins.flutter_map.** { *; }

# Latlong2
-dontwarn io.flutter.plugins.latlong2.**
-keep class io.flutter.plugins.latlong2.** { *; }

# Geolocator
-dontwarn com.baseflow.geolocator.**
-keep class com.baseflow.geolocator.** { *; }

# Permission Handler
-dontwarn com.permissionhandler.**
-keep class com.permissionhandler.** { *; }

# Shared Preferences
-dontwarn io.flutter.plugins.shared_preferences.**
-keep class io.flutter.plugins.shared_preferences.** { *; }

# Rating Bar
-dontwarn io.flutter.plugins.flutter_rating_bar.**
-keep class io.flutter.plugins.flutter_rating_bar.** { *; }

# Optimize: Remove unused Kotlin stdlib
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    static void checkNotNullParameter(...);
    static void checkNotNullExpressionValue(...);
}

# Optimize: Remove debug logs
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Keep Serialization
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
