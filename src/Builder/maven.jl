import HTTP
using HTTP: URI
using EzXML
using EzXML: Document
using ..Xml

function http_get(args...)
    println("HTTP.get($args)")
    return HTTP.get(args...)
end

function append(uri::URI, paths...)
    path = join(paths, "/")
    URI(string(uri, "/", path))
end

include("mavenrepo.jl")
include("mavenmeta.jl")
include("mavenpom.jl")

function resolve(repo::MavenRepository, dep::Dependency)
    resolve(MavenRepoDep(repo, dep))
end

function resolve(rd::MavenRepoDep)
    meta_uri = append(rd.root, "maven-metadata.xml")
    http_response = http_get(meta_uri)
    response = MavenMetadataResponse(http_response)
    resolve(rd, response)
end

function resolve(rd::MavenRepoDep, response::MavenMetadataResponse)
    dep = rd.dep
    version = dep.version
    name = dep.name

    metadata = response.body
    versioning = metadata.versioning
    versions = versioning.versions
    if version in versions
        pom_name = string(name, "-", version, ".pom")
        pom_uri = append(rd.root, version, pom_name)
        http_response = http_get(pom_uri)
        response = MavenPomResponse(http_response)
        return resolve(rd, response)
    end
    throw(InvalidStateException("version=$(dep.version) not found in $versions"))
end

function resolve(rd::MavenRepoDep, response::MavenPomResponse)
    # TODO:
    response.body
end
