import Pkg; Pkg.activate(".")

include("_mkeval.jl")
@mkeval("run")

function __init__()
    Pkg.activate(".")
end
