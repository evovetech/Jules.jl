
const Versions{N} = NTuple{N, VersionNumber}

struct MavenVersioning
    latest::VersionNumber
    release::VersionNumber
    versions::Versions
    lastUpdated::AbstractString
end

struct MavenMetadata
    groupId::AbstractString
    artifactId::AbstractString
    version::VersionNumber
    versioning::MavenVersioning
end

const MavenMetadataResponse = XmlResponse{MavenMetadata}
