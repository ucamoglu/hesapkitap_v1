# Keep Flutter entry points and plugin registrants.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep model classes used by Isar code generation.
-keep class **.models.** { *; }

# Keep Kotlin metadata used by reflection in dependencies.
-keep class kotlin.Metadata { *; }
