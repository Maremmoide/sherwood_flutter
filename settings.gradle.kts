pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()

        maven{
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication{
                create<BasicAuthentication>("basic")
            }
            credentials{
                username = "mapbox"
                password = "pk.eyJ1IjoibWFpY29sZXR0byIsImEiOiJjbHR6cTZ4N2EwMm4wMnFuNGJmMnQ2Y2FoIn0.MFlxLKBA3sT5bP2knWn11Q"
            }
        }

    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()

        maven{
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication{
                create<BasicAuthentication>("basic")
            }
            credentials{
                username = "mapbox"
                password = "pk.eyJ1IjoibWFpY29sZXR0byIsImEiOiJjbHR6cTZ4N2EwMm4wMnFuNGJmMnQ2Y2FoIn0.MFlxLKBA3sT5bP2knWn11Q"
            }
        }

    }
}

rootProject.name = "Just In Time"
include(":app")
 