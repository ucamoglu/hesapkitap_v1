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
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withId
        val getNamespace = androidExt.javaClass.methods.find { it.name == "getNamespace" }
        val setNamespace =
            androidExt.javaClass.methods.find {
                it.name == "setNamespace" && it.parameterTypes.size == 1
            }

        if (getNamespace != null && setNamespace != null) {
            val currentNamespace = getNamespace.invoke(androidExt) as? String
            if (currentNamespace.isNullOrBlank()) {
                val fallbackNamespace = "com.hesapkitap.${project.name.replace('-', '_')}"
                setNamespace.invoke(androidExt, fallbackNamespace)
            }
        }
    }
}

subprojects {
    if (name == "isar_flutter_libs") {
        // isar_flutter_libs 3.1.0+1 ships an AndroidManifest package attribute that
        // breaks on newer AGP. Strip it so namespace-based config can proceed.
        val manifestFile = file("src/main/AndroidManifest.xml")
        if (manifestFile.exists()) {
            val manifestContent = manifestFile.readText()
            val patched = manifestContent.replace(
                " package=\"dev.isar.isar_flutter_libs\"",
                "",
            )
            if (patched != manifestContent) {
                manifestFile.writeText(patched)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
