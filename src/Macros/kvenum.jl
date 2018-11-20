
macro kvenum(T, syms...)
    # enum = Expr(:macrocall, Symbol("@enum"), T)
    pairs = KvenumPairs(syms...)
    toplevel(pairs)
    # show(pairs)
    # nothing
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
