allprojects {
    repositories {
        google()
        mavenCentral()
    }

    subprojects {
        afterEvaluate {
    val project = this
            if (project.plugins.hasPlugin("com.android.library")) {
                project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
                    namespace = "com.example.carrinhodesupermercado" // Substitua pelo namespace correto
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
