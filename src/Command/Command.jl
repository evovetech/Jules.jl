module Command

abstract type Parameter end

mutable struct Argument <: Parameter

end

mutable struct Option <: Parameter
end

mutable struct Settings
end

abstract type AbstractCmd end

struct Cmd <: AbstractCmd
    name::AbstractString
    settings::Settings
end

struct Group <: AbstractCmd
    name::AbstractString
    settings::Settings
    subcmds::Vector{AbstractCmd}
end

struct Context{N}
    cmd::AbstractCmd
    args::NTuple{N, String}
end

end
