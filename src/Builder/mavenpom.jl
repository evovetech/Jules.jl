
struct MavenDependency
    groupId::AbstractString
    artifactId::AbstractString
    version::VersionNumber
    scope::AbstractString
end

const MavenDependencies{N} = NTuple{N, MavenDependency}

struct MavenPom
    groupId::AbstractString
    artifactId::AbstractString
    version::VersionNumber
    packaging::AbstractString
    dependencies::MavenDependencies
end

const MavenPomResponse = XmlResponse{MavenPom}
