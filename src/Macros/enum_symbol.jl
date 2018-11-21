
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
