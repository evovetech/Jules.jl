
struct MavenDependency
    groupId::AbstractString
    artifactId::AbstractString
    version::VersionNumber
    scope::AbstractString
end

struct MavenDeveloper
    id::AbstractString
    name::AbstractString
    email::AbstractString
end

struct MavenLicense
    name::AbstractString
    url::AbstractString
    distribution::AbstractString
end

struct MavenScm
    url::AbstractString
end

const MavenDependencies{N} = NTuple{N, MavenDependency}
const MavenDevelopers{N} = NTuple{N, MavenDeveloper}
const MavenLicenses{N} = NTuple{N, MavenLicense}

struct MavenPom
    groupId::AbstractString
    artifactId::AbstractString
    version::VersionNumber
    packaging::AbstractString
    dependencies::MavenDependencies
    licenses::MavenLicenses
    developers::MavenDevelopers
    scm::MavenScm
end

const MavenPomResponse = XmlResponse{MavenPom}

#=
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>evovetech.codegraft</groupId>
  <artifactId>inject-core</artifactId>
  <version>0.8.6</version>
  <dependencies>
    <dependency>
      <groupId>org.jetbrains.kotlin</groupId>
      <artifactId>kotlin-stdlib-jdk8</artifactId>
      <version>1.2.51</version>
      <scope>compile</scope>
    </dependency>
    <dependency>
      <groupId>evovetech.codegraft</groupId>
      <artifactId>inject-annotations</artifactId>
      <version>0.8.6</version>
      <scope>compile</scope>
    </dependency>
  </dependencies>
  <licenses>
    <license>
      <name>GNU General Public License v3.0</name>
      <url>https://www.gnu.org/licenses/lgpl.txt</url>
      <distribution>repo</distribution>
    </license>
  </licenses>
  <developers>
    <developer>
      <id>laynepenney</id>
      <name>Layne Penney</name>
      <email>layne@evove.tech</email>
    </developer>
  </developers>
  <scm>
    <url>https://github.com/evovetech/codegraft</url>
  </scm>
</project>

=#
