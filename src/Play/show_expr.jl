

function _show_expr(expr)
    println("show_expr(")
    println("$expr")
    println(")")
    return expr
end
show_expr(expr) = _show_expr(expr)

function show_expr(expr::Expr)
    if expr.head === :block
        return show_expr(expr.args)
    end
    return _show_expr(expr)
end

function show_expr(expr...)
    if length(expr) == 1
        return show_expr(expr[1])
    end
    out = Expr(:block)
    for e in expr
        push!(out.args, show_expr(e))
    end
    return out
end

macro show_expr(expr::Expr)
    return show_expr(expr)
end
