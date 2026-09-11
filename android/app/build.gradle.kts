import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.vynrix.nadodi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.vynrix.nadodi"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        // Google Play 2027: Optimize for lower memory
        vectorDrawables.useSupportLibrary = true
    }

    // Google Play 2027: Memory optimization - split APKs by ABI and density
    splits {
        abi {
            enable = true
            reset()
            include("arm64-v8a", "armeabi-v7a", "x86_64")
            universalApk = false
        }
        density {
            enable = true
            reset()
            include("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            check(keystorePropertiesFile.exists()) {
                "Release signing keystore not found: android/key.properties is missing. " +
                    "Create it before building a release APK."
            }
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            // Google Play 2027: Reduce memory footprint
            debuggable = false
            jniDebuggable = false
            renderscriptDebuggable = false
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            debuggable = true
        }
    }

    // Google Play 2027: App Bundle for dynamic delivery
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }

    packagingOptions {
        resources {
            excludes += "/META-INF/*"
        }
        jniLibs {
            pickFirsts += "lib/arm64-v8a/libflutter.so"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Google Play 2027: Credential Manager for Zero-Tap Sign-In
    implementation("androidx.credentials:credentials:1.5.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.5.0")
    implementation("com.google.android.gms:play-services-auth:21.0.0")
}