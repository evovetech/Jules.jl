
export
    Dependency,
    @dep_str

struct Dependency
    group::AbstractString
    name::AbstractString
    version::VersionNumber
end
Dependency(group::AbstractString, name::AbstractString) = Dependency(group, name, VersionNumber())
Dependency(group::AbstractString, name::AbstractString, version::AbstractString) = Dependency(group, name, VersionNumber(version))
Dependency(notation::AbstractString) = Dependency(split(notation, ":")...)

Base.show(io::IO, dep::Dependency) =
    print(dep.group, ":", dep.name, ":", dep.version)

macro dep_str(dep::String)
    Dependency(dep)
end

function root_path(dep::Dependency)
    group = replace(dep.group, "." => "/")
    name = replace(dep.name, "." => "/")
    join([group, name], "/")
end
