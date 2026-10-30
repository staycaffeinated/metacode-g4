[versions]
assertJ = '3.27.7'
junit = '6.1.3'
lombokPlugin = '9.2.0'
mockito = '5.23.0'
sonar = '7.5.0.8588'
spotless = '7.0.4'
benManesPlugin = '0.62.0'

[libraries]
assertJ = { module = "org.assertj:assertj-core", version.ref = "assertJ" }

junit-bom = { module = "org.junit:junit-bom", version.ref = "junit" }
junit-jupiter = { module = "org.junit.jupiter:junit-jupiter" }
junit-platform-launcher = { module = "org.junit.platform:junit-platform-launcher" }

mockito = { module = "org.mockito:mockito-core", version.ref = "mockito" }

[plugins]
lombok-plugin = { id = "io.freefair.lombok", version.ref = "lombokPlugin" }
sonar = { id = "org.sonarqube", version.ref = "sonar" }
versions = { id = "io.github.ben-manes.versions", version.ref = "benManesPlugin" }
