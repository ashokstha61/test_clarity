plugins {
    id("com.android.application")
    id("com.google.gms.google-services") version "4.4.1"
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.main.clarity"
    compileSdk = 35  // Updated to 35 for plugin compatibility
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.main.clarity"
        minSdk = 23
        targetSdk = 35  // Updated to match compileSdk
        versionCode = flutter.versionCode?.toInt() ?: 1
        versionName = flutter.versionName ?: "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Update Firebase BOM to latest stable version
    implementation(platform("com.google.firebase:firebase-bom:33.0.0"))
    
    // Explicitly add these with versions from the BOM
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-database-ktx") // Note the -ktx suffix
    
    // Add these critical dependencies
    implementation("com.google.android.gms:play-services-base:18.4.0")
    implementation("com.google.firebase:firebase-common-ktx:20.4.2")
    
    implementation("androidx.multidex:multidex:2.0.1")
}