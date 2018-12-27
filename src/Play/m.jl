

function pad(n::Integer; del=" ", size=2, str="")
    prefix = ""
    for i in 1:n, j in 1:size
        prefix *= del
    end
    return prefix * str
end

mutable struct M
    level::Integer
end

function m(expr::Expr, level::Integer)
    args = expr.args
    str = pad(level; str="$(typeof(expr))[:$(expr.head)]{\n")
    len = length(args)
    for i in 1:len
        str *= m(args[i], level+1)
        if i < len
            str *= ", "
        end
        str *= "\n"
    end
    return str * pad(level; str="}")
end
m(expr::Symbol, level::Integer) = pad(level) * ":$(expr)"
m(expr::String, level::Integer) = pad(level) * "\"$(expr)\""
m(expr::QuoteNode, level::Integer) = m(expr.value, level)
m(expr, level::Integer) = pad(level) * "$(typeof(expr))[$(expr)]"

macro m(expr)
    str = m(expr, 0)
    println("$(str)")
    return expr
end
