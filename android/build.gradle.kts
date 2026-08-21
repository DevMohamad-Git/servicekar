allprojects {
    repositories {
        // dl.google.com is unreachable from this network (HTTP 404 for AGP
        // and AndroidX artifacts), so route Google / AndroidX lookups
        // through the Aliyun mirror. Maven Central stays direct — it works.
        // Flutter engine binaries (io.flutter:flutter_embedding_debug plus
        // the per-ABI *_debug .so jars) live under download.flutter.io on
        // Google Cloud Storage, which is reachable, so declare it explicitly
        // so the Flutter Gradle Plugin does not have to inject it.
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
