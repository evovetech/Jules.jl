
toplevel(args...) = Expr(:toplevel, args...)

macrocall(
    sym::Symbol,
    args...
) = Expr(:macrocall, sym, args...)

macrocall(
    sym::String,
    args...
) = macrocall(Symbol("@", sym), args...)
