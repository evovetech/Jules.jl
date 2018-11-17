import Pkg; Pkg.activate(".")

include("_make_evalfile.jl")

@make_evalfile :tmp
@make_evalfile :j2

function __init__()
    Pkg.activate(".")
end
