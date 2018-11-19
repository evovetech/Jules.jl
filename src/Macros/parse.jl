
macro parse(args::Any...)
    for arg in parse_macroargs(args...)
        show(arg)
        println()
    end
    return nothing
end

function parse_macroarg(arg::Expr)
    if arg.head === :macrocall
        if arg.args[1] ∈ (Symbol("@enum_symbol"), Symbol("@kvenum"))
            arg = macroexpand(@__MODULE__, arg, recursive=false)
        end
    end
    MacroVal(arg)
end
parse_macroarg(arg) = MacroVal(arg)

parse_macroargs(args::Any...) = [parse_macroarg(arg) for arg in args]
parse_macroargs(args::Tuple) = parse_macroargs(args...)
parse_macroargs(args::Vector{Any}) = parse_macroargs(args...)
