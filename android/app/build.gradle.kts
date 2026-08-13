import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingProperties = Properties()
val signingPropertiesFile = rootProject.file("key.properties")
if (signingPropertiesFile.exists()) {
    FileInputStream(signingPropertiesFile).use(signingProperties::load)
}

val releaseStoreFile = signingProperties["storeFile"] as String?
val releaseStorePassword = signingProperties["storePassword"] as String?
val releaseKeyAlias = signingProperties["keyAlias"] as String?
val releaseKeyPassword = signingProperties["keyPassword"] as String?
val environment = System.getenv()
val resolvedReleaseStoreFile = releaseStoreFile ?: environment["AUMIAU_ANDROID_STORE_FILE"]
val resolvedReleaseStorePassword = releaseStorePassword ?: environment["AUMIAU_ANDROID_STORE_PASSWORD"]
val resolvedReleaseKeyAlias = releaseKeyAlias ?: environment["AUMIAU_ANDROID_KEY_ALIAS"]
val resolvedReleaseKeyPassword = releaseKeyPassword ?: environment["AUMIAU_ANDROID_KEY_PASSWORD"]
val hasReleaseSigning = listOf(
    resolvedReleaseStoreFile,
    resolvedReleaseStorePassword,
    resolvedReleaseKeyAlias,
    resolvedReleaseKeyPassword,
).all { !it.isNullOrBlank() } && resolvedReleaseStoreFile?.let(::File)?.exists() == true

android {
    namespace = "com.aumiau.aumiau_app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.aumiau.aumiau_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasReleaseSigning) {
        signingConfigs {
            create("release") {
                storeFile = file(resolvedReleaseStoreFile!!)
                storePassword = resolvedReleaseStorePassword!!
                keyAlias = resolvedReleaseKeyAlias!!
                keyPassword = resolvedReleaseKeyPassword!!
            }
        }
    }

    buildTypes {
        debug {
            // Mantém o APK de teste instalável ao lado da versão publicada,
            // sem apagar os dados do aplicativo de produção.
            applicationIdSuffix = ".debug"
        }
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Permite apenas validação local quando a chave oficial não
                // estiver disponível. Este artefato não pode ser publicado.
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
