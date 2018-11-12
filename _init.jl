import Pkg; Pkg.activate(".")

export @tmp

macro tmp(args::Vector{String})
    args = [string(a) for a in args]
    return quote
        evalfile("src/tmp.jl", $(args))
    end
end

function __init__()
    Pkg.activate(".")
end
