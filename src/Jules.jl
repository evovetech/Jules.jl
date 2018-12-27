module Jules

export Maybe

const Maybe{T} = Union{T,Nothing}

include("Log/Log.jl")
include("context.jl")
include("functions.jl")
include("Command/Command.jl")
include("Macros/Macros.jl")
include("Xml/Xml.jl")
include("Builder/Builder.jl")

#play
include("Play/Play.jl")

end # module
