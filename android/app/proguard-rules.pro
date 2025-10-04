# Keep SLF4J classes (used by Zoho SalesIQ and other libraries)
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Keep Zoho SalesIQ classes
-keep class com.zoho.** { *; }
-dontwarn com.zoho.**

# Keep classes referenced by Zoho SalesIQ
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# AndroidX and Support Library compatibility
-dontwarn android.support.**
-keep class android.support.** { *; }

# Preserve generic signatures
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

