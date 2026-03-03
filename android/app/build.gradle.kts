import java.util.Properties
import java.io.FileInputStream

// Load local.properties (for flutter.sdk etc.)
val localProperties = Properties().apply {
    val localPropsFile = rootProject.file("local.properties")
    if (localPropsFile.exists()) {
        load(FileInputStream(localPropsFile))
    }
}

// Load signing from key.properties
val keyProperties = Properties().apply {
    val keyPropsFile = rootProject.file("key.properties")
    if (keyPropsFile.exists()) {
        load(FileInputStream(keyPropsFile))
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.guru.oral_app_new"
    compileSdk = 36  // ← Changed: Required by plugins & AndroidX deps

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.guru.oral_app_new"
        minSdk = flutter.minSdkVersion  // Keep as-is (likely 21-24)
        targetSdk = 36  // ← Also bump this for best compatibility
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile      = keyProperties.getProperty("storeFile")?.let { file(it) }
            storePassword  = keyProperties.getProperty("storePassword")
            keyAlias       = keyProperties.getProperty("keyAlias")
            keyPassword    = keyProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // Uncomment for production release (shrinks APK/AAB size):
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}