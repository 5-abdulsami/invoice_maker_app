# R8 rules for release builds.
#
# Release builds shrink and obfuscate the Android code. The Flutter engine and
# its plugins are reached through JNI and reflection, so their entry points
# have to be kept explicitly or the app crashes on launch.

# Flutter engine and the generated plugin registrant.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# The engine references Play Core for deferred components. This app does not
# use them and does not bundle the library, so R8 must not fail on it.
-dontwarn com.google.android.play.core.**

# Keep annotations used by the plugins' generated Pigeon message channels.
-keepattributes *Annotation*

# Kotlin metadata, read by some plugins at runtime.
-keep class kotlin.Metadata { *; }
