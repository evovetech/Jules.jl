function mkevalfile(path::AbstractString, args::Vararg{Any,N} where N)
    args = [string(a) for a in args]
    :(evalfile($path, $args))
end

function mkevalfile(path::AbstractString)
    name = Symbol(basename(path)[1:end-3])
    return quote
        macro $(esc(name))(args::Vararg{Any,N} where N)
            mkevalfile($path, args...)
        end
    end
end

macro mkeval(dir::AbstractString)
    paths = (joinpath(dir, file)
        for file in readdir(dir)
        if endswith(file, ".jl"))
    top = Expr(:block)
    for path in paths
        push!(top.args, mkevalfile(path))
    end
    return top
end
