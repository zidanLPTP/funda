allprojects {
    repositories {
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
    if (project.name != "app") {
        afterEvaluate {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                    defaultConfig.javaClass.getMethod("setMinSdkVersion", Any::class.java).invoke(defaultConfig, 23)
                } catch (_: Exception) {
                    try {
                        val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                        defaultConfig.javaClass.getMethod("minSdkVersion", Int::class.javaPrimitiveType).invoke(defaultConfig, 23)
                    } catch (_: Exception) {}
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
