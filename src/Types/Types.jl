module Types

export
    Getter,
    Field,
    TypeInfo

function Base.NamedTuple(names::NTuple{N,Symbol}, args::T) where {N,T<:Tuple}
    NamedTuple{names,T}(args)
end
# function Base.convert(::NTuple{N,Symbol}, nt::NTuple{N})

struct Getter{R,T}
    index::Int
    func::Function

    function Getter{R,T}(index::Int) where {R,T}
        f = T.mutable ? _mutableget : _get
        new{R,T}(index, f)
    end
end
(g::Getter{R,T})(obj::T) where {R,T} = g.func(g, obj)

@inline function _mutableget(g::Getter{R,T}, obj::T) where {R,T}
    i = g.index
    isdefined(obj, i) ? getfield(obj, i)::R : missing
end
@inline function _get(g::Getter{R,T}, obj::T) where {R,T}
    getfield(obj, g.index)::R
end

struct Field{T}
    offset::UInt
    get::Getter{T}
end
function Field(offset::UInt, getter::Getter{T}) where T
    Field{T}(offset, getter)
end
function Field(::Type{T},i) where T
    offset,R = (fieldoffset(T,i), fieldtype(T,i))
    getter = Getter{R,T}(i)
    Field(offset, getter)
end

abstract type TypeInfo end

struct UnionAllTypeInfo <: TypeInfo
    var::Core.TypeVar
    body::TypeInfo
end
UnionAllTypeInfo(T::UnionAll) = UnionAllTypeInfo(T.var, T.body)

struct UnionTypeInfo <: TypeInfo
   a::TypeInfo
   b::TypeInfo
end
UnionTypeInfo(T::Union) = UnionTypeInfo(T.a, T.b)

struct UnknownTypeInfo <: TypeInfo
    T::Type
end

abstract type DataTypeInfo <: TypeInfo end

struct IncompleteTypeInfo <: DataTypeInfo
    T::DataType
end

struct ConcreteDataTypeInfo{T, NT<:NamedTuple} <: DataTypeInfo
    mutable::Bool
    fields::NT

    function ConcreteDataTypeInfo{T}(fields::NT) where {T, NT<:NamedTuple}
        new{T,NT}(T.mutable, fields)
    end
end
@generated function ConcreteDataTypeInfo(::Type{T}) where T
    N = fieldcount(T)
    names = ntuple(i -> fieldname(T, i), N)
    infos = ntuple(i -> Field(T, i), N)
    fields = NamedTuple(names,infos)
    ConcreteDataTypeInfo{T}(fields)
end
Base.propertynames(st::ConcreteDataTypeInfo) = (fieldnames(ConcreteDataTypeInfo)..., propertynames(st.fields)...)
Base.getproperty(st::ConcreteDataTypeInfo, name::Symbol) = begin
    if name ∈ fieldnames(ConcreteDataTypeInfo)
        return getfield(st, name)
    end
    getproperty(st.fields, name)
end

const Struct = ConcreteDataTypeInfo
@inline function DataTypeInfo(T::DataType)
    T.isconcretetype ? ConcreteDataTypeInfo(T) : IncompleteTypeInfo(T)
end

@inline TypeInfo(x) = TypeInfo(typeof(x))
@inline TypeInfo(T::Type) = UnknownTypeInfo(T)
@inline TypeInfo(T::DataType) = DataTypeInfo(T)
@inline TypeInfo(T::UnionAll) = UnionAllTypeInfo(T)
@inline TypeInfo(T::Union) = UnionTypeInfo(T)

Base.convert(::Type{TypeInfo}, x::TypeInfo) = x
Base.convert(::Type{TypeInfo}, x) = TypeInfo(x)

using ..Log

function Base.show(io::IO, dt::ConcreteDataTypeInfo{T}) where T
    print(io, "ConcreteDataTypeInfo{")
    show(io, T)
    print(io, "}")

    length(dt.fields) > 0 || return
    indent(io) do io::IO
        for (n,f) in pairs(dt.fields)
            println(io)
            indent(io)
            print(io, n)
            print(io, " = ")
            show(io, f)
        end
    end
end

function Base.show(io::IO, field::Field{T}) where {T}
    print(io, "Field{")
    show(io, T)
    print(io, "}(")
    print(io, "index=")
    show(io, field.get.index)
    print(io, ", offset=")
    show(io, field.offset)
    print(io, ")")
end

module Structs
    using ..Types

    const DataType = TypeInfo(Core.DataType)
    const TypeName = TypeInfo(Core.TypeName)
end

end

#=

=#
