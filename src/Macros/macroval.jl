
abstract type MacroVal end

struct MacroArg{T} <: MacroVal
    value::T
end

struct MacroExpr <: MacroVal
    typ::MaybeExprType
    args::Vector{MacroVal}
end

MacroVal(arg) = MacroArg(arg)
# MacroVal(arg::Symbol) = MacroSymbol(arg)
# MacroVal(arg::QuoteNode) = MacroVal(arg.value)
MacroVal(arg::Expr) = MacroExpr(arg)

function MacroExpr(expr::Expr)
    typ = MaybeExprType(expr)
    args = [MacroVal(arg) for arg in expr.args]
    MacroExpr(typ, args)
end

function Base.show(io::IO, arg::MacroArg{T}) where {T}
    indent(io)
    print(io, "MacroArg{$(T)}(")
    show(io, arg.value)
    print(io, ")")
end

# Base.show(io::IO, arg::MacroArg) = _show_value(io, MacroArg, arg.value)
# Base.show(io::IO, arg::MacroSymbol) = _show_value(io, MacroSymbol, arg.value)

function Base.show(io::IO, expr::MacroExpr)
    indent(io)
    print(io, "$(expr.typ)(")
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
