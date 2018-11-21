
macro kvenum(T, syms...)
    # enum = Expr(:macrocall, Symbol("@enum"), T)
    pairs = KvenumPairs(syms...)
    enum = :(@enum $T)
    for (sym, T2) in pairs
        push!(enum.args, T2)
    end
    blk = Expr(:block)
    push!(blk.args, esc(enum))

    # types = :(__exprtypes = Dict($pairs))
    # push!(blk.args, esc(types))

    type = T
    if isa(T, Expr) && T.head === :(::)
        type = T.args[1]
    end

    for (sym, T2) in pairs
        expr = :(Macros.head(::Macros.ExprVal{$(esc(T2))}) = $(esc(sym)))
        push!(blk.args, expr)
    end

    head = :(@inline Macros.head(e::$(esc(type))) = Macros.head(Macros.ExprVal(e)))
    push!(blk.args, head)

    # show(pairs)
    # nothing
    show(macroexpand(__module__, blk))
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
