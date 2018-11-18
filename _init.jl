import Pkg; Pkg.activate(".")

include("_make_evalfile.jl")

@make_evalfile :tmp
@make_evalfile :j2
@make_evalfile :mackro

function __init__()
    Pkg.activate(".")
end
