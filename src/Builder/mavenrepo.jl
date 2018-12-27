export
    MavenRepository,
    jcenter

struct MavenRepository <: Repository
    url::URI

    MavenRepository(; kwargs...) = new(URI(; kwargs...))
    MavenRepository(url) = new(URI(url))
end

jcenter() = MavenRepository("https://jcenter.bintray.com")

root_uri(
    repo::MavenRepository,
    dep::Dependency
) = append(repo.url, root_path(dep))

struct MavenRepoDep
    repo::MavenRepository
    dep::Dependency
    root::URI

    MavenRepoDep(repo::MavenRepository, dep::Dependency) =
        new(repo, dep, root_uri(repo, dep))
end
