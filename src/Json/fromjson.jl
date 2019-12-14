#=
fromjson:
- Julia version:
- Author: layne
- Date: 2019-05-09
=#

export fromjson

@generated function fromjson(::Type{T}, json::Dict) where T
    fromjson_impl(T, json)
end
fromjson(::Type{Maybe{T}}, json::Dict) where T = fromjson(T, json)

fromjson(::Type{T}, ::Nothing) where T = nothing
fromjson(::Type{I}, ::Nothing) where {I<:Integer} = 0
fromjson(::Type{<:AbstractString}, ::Nothing) = ""
fromjson(::Type{VersionNumber}, ::Nothing) = typemin(VersionNumber)
fromjson(::Type{Vector{T}}, ::Nothing) where T = T[]

fromjson(::Type{<:Any}, json) = json
fromjson(::Type{I}, json) where {I<:Integer} = I(json)
fromjson(::Type{<:AbstractString}, json) = string(json)
fromjson(::Type{VersionNumber}, json) = VersionNumber(string(json))
function fromjson(::Type{Vector{T}}, json) where T
    values = T[]
    for item in json
        push!(values, fromjson(T, item))
    end
    values
end


abstract type AbstractParser{T} end
struct StructParser{T} <: AbstractParser{T}

end


struct Parser{T}
    key::AbstractString
end
Parser(::Type{T}, key) where T = Parser{T}(key)

#= TODO:
For each Type{T}, we can generate a methods that will recursively generate
the expression for parsing all of the fields so that there aren't any
extra steps at runtime. Right now, the generated function isn't recursively
processing the field types
=#
@inline parse(p::Parser{T}, json::Dict) where T = fromjson(T, json[p.key])
@inline parse(p::Parser{Maybe{T}}, json::Dict) where T = begin
    if haskey(json, p.key)
        return fromjson(T, json[p.key])
    end
    nothing
end

function fromjson_impl(::Type{T}, json::Type{<:Dict}) where T
    names = fieldnames(T)
    types = T.types

    ex = Expr(:tuple)
    for i in eachindex(types)
        fname = names[i]
        ftype = types[i]

        key = :( $(string(fname)) )
        parser = :( $(Parser(ftype, key)) )
        push!(ex.args, :( parse($parser, json) ))
    end
    :( $(T)($(ex)...) )
end
