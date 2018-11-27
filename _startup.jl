# startup init
struct FileStatus
    path::AbstractString
    found::Bool

    function FileStatus(dir::AbstractString, file::AbstractString)
        path = joinpath(dir, file)
        new(path, isfile(path))
    end
end
FileStatus(file::AbstractString) = FileStatus(pwd(), file)

macro filestatus(file::AbstractString)
    :(FileStatus($file))
end

macro isfile(file::AbstractString)
    :(FileStatus($file).found)
end

if @isfile("Project.toml")
    import Pkg; Pkg.activate(".")
    println("Project: $(basename(pwd()))")
end

let st = @filestatus("_init.jl")
    if st.found
        include(st.path)
        println("include(path=$(st.path))")
    end
end
