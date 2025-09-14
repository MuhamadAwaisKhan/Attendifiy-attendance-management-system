plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.attendencemanamentsysytem.attendencesystem"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        // ✅ Enable desugaring - CORRECTED SYNTAX
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.attendencemanamentsysytem.attendencesystem"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // CORRECTED: Use parentheses instead of quotes and proper syntax
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22") // Kotlin JDK 8
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // ✅ desugaring lib
}