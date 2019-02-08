

function _show_expr(expr)
    println("$expr")
    return expr
end
show_expr(expr) = _show_expr(expr)

function show_expr(expr::Expr)
    if expr.head === :block
        for e in expr.args
            show_expr(e)
        end
        return expr.args
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

macro show_expr(expr...)
    println("show_expr(")
    ret = show_expr(expr...)
    println(")")
    return ret
end
