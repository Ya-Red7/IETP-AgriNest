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
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // AgriNest Application ID - unique identifier for Google Play Store and app distribution
        applicationId = "com.agrinest.farm"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // TODO: Configure these values for production signing
            // Generate keystore using: keytool -genkey -v -keystore app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias app
            // Store keystore.jks in android/app/ directory (add to .gitignore)
            // Set environment variables or use local.properties file for security

            storeFile = file("keystore.jks")
            storePassword = System.getenv("AGRI_KEYSTORE_PASSWORD") ?: "agrinest123"
            keyAlias = System.getenv("AGRI_KEY_ALIAS") ?: "agrinest"
            keyPassword = System.getenv("AGRI_KEY_PASSWORD") ?: "agrinest123"
        }
    }

    buildTypes {
        release {
            // Production signing configuration
            signingConfig = signingConfigs.getByName("release")

            // Enable code shrinking and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // Strip debug symbols for smaller APK
            ndk {
                debugSymbolLevel = "NONE"
            }
        }

        debug {
            // Debug signing configuration (automatically configured by Flutter)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a")
            isUniversalApk = false
        }
    }
}

flutter {
    source = "../.."
}
