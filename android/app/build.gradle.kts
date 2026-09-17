import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")

    // The Flutter Gradle Plugin must be applied after
    // the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

android {
    namespace = "it.francescofasolato.boardgameplayer"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "it.francescofasolato.boardgameplayer"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (!keystorePropertiesFile.exists()) {
                throw GradleException(
                    "File android/key.properties non trovato. " +
                        "Crearlo prima di generare la build release."
                )
            }

            keyAlias = keystoreProperties.getProperty("keyAlias")
                ?: throw GradleException(
                    "Proprietà keyAlias mancante in android/key.properties."
                )

            keyPassword = keystoreProperties.getProperty("keyPassword")
                ?: throw GradleException(
                    "Proprietà keyPassword mancante in android/key.properties."
                )

            storePassword = keystoreProperties.getProperty("storePassword")
                ?: throw GradleException(
                    "Proprietà storePassword mancante in android/key.properties."
                )

            val storeFilePath =
                keystoreProperties.getProperty("storeFile")
                    ?: throw GradleException(
                        "Proprietà storeFile mancante in android/key.properties."
                    )

            storeFile = file(storeFilePath)
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
