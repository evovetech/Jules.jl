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

parse_macroargs(args::Any...) = [MacroVal(arg) for arg in args]
parse_macroargs(args::Tuple) = parse_macroargs(args...)
parse_macroargs(args::Vector{Any}) = parse_macroargs(args...)

macro parse(args::Any...)
    for arg in parse_macroargs(args...)
        show(arg)
        println()
    end
    return nothing
end

end
