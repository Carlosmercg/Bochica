import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// 🔹 Repositorios globales
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔹 Define la carpeta de build global
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// 🔹 Dependencias del subproyecto app
subprojects {
    project.evaluationDependsOn(":app")
}

// 🔹 Tarea clean global
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 🔹 Bloque buildscript (Kotlin DSL corregido)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23")
        classpath("com.google.gms:google-services:4.4.2") // ✅ Firebase
    }
}
