module Macros

using ..Log

include("expr.jl")

export @parse

abstract type MacroVal end

struct MacroArg{T} <: MacroVal
    value::T
end

struct MacroExpr <: MacroVal
    type::MaybeExprType
    args::Vector{MacroVal}
end

MacroVal(arg) = MacroArg(arg)
# MacroVal(arg::Symbol) = MacroSymbol(arg)
# MacroVal(arg::QuoteNode) = MacroVal(arg.value)
MacroVal(arg::Expr) = MacroExpr(arg)

function MacroExpr(expr::Expr)
    type = MaybeExprType(expr)
    args = [MacroVal(arg) for arg in expr.args]
    MacroExpr(type, args)
end

function Base.show(io::IO, val::MacroVal)
    indent(io)
    # print(io, "$(T)(")
    Base.show_default(io, val)
    # print(io, ")")
end

# Base.show(io::IO, arg::MacroArg) = _show_value(io, MacroArg, arg.value)
# Base.show(io::IO, arg::MacroSymbol) = _show_value(io, MacroSymbol, arg.value)

function Base.show(io::IO, expr::MacroExpr)
    indent(io)
    print(io, "$(expr.type)(")
    indent(io) do io::IO
        for (i, arg) in enumerate(expr.args)
            if i > 1
                print(io, ", ")
            end
            println()
            show(io, arg)
        end
        println()
    end
    indent(io)
    print(io, ")")
end

parse_macroarg(arg) = MacroVal(arg)
function parse_macroarg(arg::Expr)
    if arg.head === :macrocall
        if arg.args[1] ∈ (Symbol("@enum_symbol"), Symbol("@kvenum"))
            arg = macroexpand(@__MODULE__, arg, recursive=false)
        end
    end
    MacroVal(arg)
end
parse_macroargs(args::Any...) = [parse_macroarg(arg) for arg in args]
parse_macroargs(args::Tuple) = parse_macroargs(args...)
parse_macroargs(args::Vector{Any}) = parse_macroargs(args...)

macro parse(args::Any...)
    for arg in parse_macroargs(args...)
        show(arg)
        println()
    end
    return nothing
end

using Base

function Base.push!(args::Vector{Any}, sym::LineNumberNode)
    # no-op
end

Base.push!(expr::Expr, sym) = push!(expr.args, sym)

function Base.push!(expr::Expr, sym::Expr)
    if sym.head === :block
        block = Expr(:block)
        for arg in sym.args
            push!(block, arg)
        end
        sym = block
    end

    push!(expr.args, sym)
    return nothing
end

macro enum_symbol(T, syms...)
    enum = Expr(:macrocall, Symbol("@enum"), T)
    for sym in syms
        push!(enum, sym)
    end
    Expr(:toplevel, enum)
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
KvenumPairs(sym::KvenumPair)::KvenumPairs{1} = (sym,)
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

macro kvenum(T, syms...)
    # enum = Expr(:macrocall, Symbol("@enum"), T)
    pairs = KvenumPairs(syms...)
    Expr(:toplevel, pairs)
    # show(pairs)
    # nothing
end

#=
@parse @enum_symbol ExprType2::UInt8 begin
    A = 0
    B
    C
end
=#

@parse @kvenum ExprType3::UInt8 begin
    :unknown    => UnknownExpr
    :call       => CallExpr
end

end
