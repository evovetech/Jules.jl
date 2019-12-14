structinfo(T,i) = (fieldoffset(T,i), fieldname(T,i), fieldtype(T,i))
structinfo(T) = [structinfo(T,i) for i = 1:fieldcount(T)]

const Value{T} = Union{T,Missing}

####

function Base.NamedTuple(names::NTuple{N,Symbol}, args::T) where {N, T <: Tuple}
    NamedTuple{names,T}(args)
end
# function Base.NamedTuple(fields::Vararg{FieldInfo{T},N}) where {T,N}
#     names = ntuple(i -> fields[i].name, N)
#     return NamedTuple(names, fields)
# end

struct Getter2{R,T}
    index::Int
end
function (g::Getter2{R,T})(obj::T)::Value{R} where {T,R}
    i = g.index
    isdefined(obj, i) ? getfield(obj, i) : missing
end

struct FieldInfo2{R,T}
    offset::Uint
    get::Getter2{R,T}
end
function FieldInfo2(offset::UInt, getter::Getter2{R,T}) where {R,T}
    FieldInfo2{T,R}(offset, getter)
end
function FieldInfo2(::Type{T},i) where T
    offset,R = (fieldoffset(T,i), fieldtype(T,i))
    getter = Getter2{T,R}(i)
    FieldInfo2(offset, getter)
end

struct StructInfo2{T, NT<:NamedTuple}
    fields::NT

    function StructInfo2{T}(fields::NT) where {T, NT<:NamedTuple}
        new{T,NT}(fields)
    end
    function StructInfo2(::Type{T}) where T
        N = fieldcount(T)
        names = ntuple(i -> fieldname(T, i), N)
        infos = ntuple(i -> FieldInfo2(T, i), N)
        fields = NamedTuple(names,infos)
        StructInfo2{T}(fields)
    end
end

####

struct Getter{T,R}
    index::Int
end
function (g::Getter{T,R})(obj::T)::Value{R} where {T,R}
    i = g.index
    isdefined(obj, i) ? getfield(obj, i) : missing
end

struct FieldInfo{T,R}
    offset::UInt
    fname::Symbol
    get::Getter{T,R}
end
function FieldInfo(offset::UInt,fname::Symbol, getter::Getter{T,R}) where {T,R}
    return FieldInfo{T,R}(offset,fname,getter)
end
function FieldInfo(::Type{T},i) where T
    offset,fname,ftype = structinfo(T, i)
    getter = Getter{T,ftype}(i)
    return FieldInfo(offset, fname, getter)
end

struct StructInfo{T,N}
    fields::NTuple{N, FieldInfo{T}}

    function StructInfo{T,N}() where {T,N}
        fields = ntuple(i -> FieldInfo(T,i), N)
        new{T,N}(fields)
    end
end
StructInfo(::Type{T}) where T =  StructInfo{T,fieldcount(T)}()
StructInfo(obj) = StructInfo(typeof(obj))


_name(T) = nothing
_name(T::DataType) = T.name
_name(T::UnionAll) = _name(T.body)
_name(T::Union) = string("Union{", join(_names(T.a,T.b), ", "), "}")
_names(args...) = map(_name, map(typeof, args))

function _t2(dt::TT) where TT<:Type{T} where T
#     dump(TT)
    n = _name(T)
    n !== nothing ? show(n) : nothing
    print("::")
    show(TT.name)
    println()
    for i = 1:fieldcount(TT)
        info = structinfo(TT,i)
        offset,name,typ = info
        print("  ", name, "::", typ, " = ")
        val = isdefined(dt, i) ? getfield(dt, i) : :undefined
        show(val)
        println()
#         show(getproperty(dt, n)); println()
    end
    println()
#     dump(T)
end
