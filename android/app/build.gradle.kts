//import java.util.Properties
//import java.io.FileInputStream
//
//plugins {
//    id("com.android.application")
//    id("org.jetbrains.kotlin.android")
//    id("dev.flutter.flutter-gradle-plugin")
//    id("com.google.gms.google-services")
//}
//
//val keystorePropertiesFile = rootProject.file("key.properties")
//val keystoreProperties = Properties()
//
//if (keystorePropertiesFile.exists()) {
//    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
//}
//
//android {
//    namespace = "com.example.maamaaspartner"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = "28.2.13676358"
//    compileOptions {
//        isCoreLibraryDesugaringEnabled = true
//        sourceCompatibility = JavaVersion.VERSION_17
//        targetCompatibility = JavaVersion.VERSION_17
//    }
//
//    kotlinOptions {
//        jvmTarget = "17"
//    }
//
//    signingConfigs {
//        create("release") {
//            keyAlias = keystoreProperties["keyAlias"] as String?
//            keyPassword = keystoreProperties["keyPassword"] as String?
//            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
//            storePassword = keystoreProperties["storePassword"] as String?
//        }
//    }
//
//    defaultConfig {
//        applicationId = "com.maamaas.partner"
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    buildTypes {
//        getByName("release") {
//            signingConfig = signingConfigs.getByName("release")
//            isMinifyEnabled = true
//            isShrinkResources = true
//            isDebuggable = false
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
//        }
//    }
//}
//
//
//dependencies {
//    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
//}
//
//
//flutter {
//    source = "../.."
//}


import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.maamaaspartner"
    compileSdk = 36
    ndkVersion = "28.2.13676358"
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "com.maamaas.partner"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}


dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}


dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    implementation("com.google.firebase:firebase-messaging-ktx")
}

flutter {
    source = "../.."
}
