import Pkg

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

function include(st::FileStatus)
    st.found || return

    try
        include(st.path)
        println("include(path=$(st.path))")
    catch e
        println("error=$e")
    end
end

macro filestatus(file::AbstractString)
    :(FileStatus($file))
end

macro isfile(file::AbstractString)
    :(FileStatus($file).found)
end

_instantiate() = try
    Pkg.instantiate()
catch
    println("could not instantiate")
end

_activate(dir=".") = try
    Pkg.activate(dir)
catch
    println("could not activate dir=$dir")
    _instantiate()
end

if @isfile("Project.toml")
    _activate()
    println("Project: $(basename(pwd()))")
end

let st = @filestatus("_init.jl")
    include(st)
end
