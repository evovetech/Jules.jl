
include("macroenv.jl")

const KvenumType{T<:Integer} = Typedef{T}

function gen_valtype(typedef, pairs)
    typename = typedef.name
    valtype = Symbol(typename, "Val")
    blk = quote
        struct $(valtype){T} end
        $(valtype)(x) = (Base.@_pure_meta; $(valtype){x}())

        head(::$(valtype)) = :unknown
        express(@nospecialize(e)) = Expr(head(e))
        @inline head(e::$(typename)) = head($(valtype)(e))
    end

    for (sym, T2) in pairs
        push!(blk.args, :(head(::$(valtype){$(T2)}) = $(sym)))
    end
    push!(blk.args, :nothing)
    blk.head = :toplevel
    return blk
end

function gen_enum(typedef, pairs)
    typename = typedef.name
    basetype = gettype(typedef)
    enum = :(@enum $typename::$basetype)
    for (sym, T2) in pairs
        push!(enum.args, T2)
    end
    return enum
end

macro kvenum(T, syms...)
    env = @macroenv()
    typedef = parsetype(env, T)
    pairs = KvenumPairs(syms...)
    enum = gen_enum(typedef, pairs)
    valgen = gen_valtype(typedef, pairs)
    blk = quote
        $(esc(enum))
        $(esc(valgen))
    end
    show(macroexpand(env.mod, blk))
    blk
end

const KvenumArg = Union{QuoteNode,Symbol}
KvenumArg(sym) = error("'$(sym)' must be a symbol")
KvenumArg(sym::Symbol) = sym
function KvenumArg(sym::QuoteNode)
    @assert isa(sym.value, Symbol)
    sym
end

const KvenumPair = Pair{KvenumArg, KvenumArg}
KvenumPair(sym) = error("'$(sym)' must be an expression")
function KvenumPair(sym::Expr)
    if sym.head === :call
        sym = Expr(sym.args...)
    end

    @assert sym.head ∈ (:(=), :(=>))
    args = [KvenumArg(arg) for arg in sym.args]
    KvenumPair(args...)
end
function Base.show(io::IO, pair::KvenumPair)
    print(io, "(")
    show(io, pair.first)
    print(io, " => ")
    show(io, pair.second)
    print(")")
end

const KvenumPairs{N} = NTuple{N, KvenumPair} where {N}
KvenumPairs() = ()::KvenumPairs{0}
KvenumPairs(sym::LineNumberNode) = KvenumPairs()
KvenumPairs(sym)::KvenumPairs{1} = (KvenumPair(sym),)
function KvenumPairs(sym::Expr)
    if sym.head === :block
        return KvenumPairs(sym.args...)
    end
    (KvenumPair(sym),)
end
function KvenumPairs(syms...)
    pairs = []
    for sym in syms
        push!(pairs, KvenumPairs(sym)...)
    end
    (pairs...,)
end
function Base.show(io::IO, pairs::KvenumPairs{N}) where {N}
    indent(io)
    print(io, "(")
    indent(io) do io::IO
        for i in 1:N
            if i > 1
                print(io, ", ")
            end
            println(io)
            indent(io)
            print(io, "$i=")
            show(io, pairs[i])
        end
        println(io)
    end
    indent(io)
    print(io, ")")
end
