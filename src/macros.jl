module Macros

export @parse

function indent(io::IO)
    level = get(io, :level, 0)
    for i in 1:level
        print(io, "  ")
    end
end

function indent(f::Function, io::IO)
    level = get(io, :level, 0)
    let io = IOContext(io, :level => level + 1)
        f(io)
    end
end

abstract type MacroVal end

struct MacroArg{T} <: MacroVal
    value::T
end

struct MacroExpr <: MacroVal
    head::Symbol
    args::Array{MacroVal, 1}

    function MacroExpr(expr::Expr)
        args = [MacroVal(arg) for arg in expr.args]
        new(expr.head, args)
    end
end

MacroVal(arg) = MacroArg(arg)
MacroVal(arg::QuoteNode) = MacroArg(arg.value)
MacroVal(arg::Expr) = MacroExpr(arg)

function Base.show(io::IO, arg::MacroArg)
    indent(io)
    print(io, "MacroArg(")
    show(io, arg.value)
    print(io, ")")
end

function Base.show(io::IO, expr::MacroExpr)
    indent(io)
    print(io, "MacroExpr[$(expr.head)](")
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
