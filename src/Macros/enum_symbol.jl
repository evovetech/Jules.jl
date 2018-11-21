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

macro enum_wrap1(T, syms...)
    esc(:($(Expr(:macrocall, Symbol("@enum"), __source__, T, syms...))))
end

macro enum_wrap2(T, syms...)
    esc(:(@enum($T, $(syms...))))
end

macro enum_wrap3(T, syms...)
    args = (T, syms...)
    expr = :(@enum)
    push!(expr.args, args...)
    esc(expr)
end
