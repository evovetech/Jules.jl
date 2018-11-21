module Macros

using Base
using ..Log

export @parse, @kvenum

for i in 1:3
    eval(Meta.parse("export @enum_wrap$i"))
end

using Base: @_pure_meta
struct ExprVal{T} end
ExprVal(x) = (@_pure_meta; ExprVal{x}())
head(::ExprVal) = :unknown
express(@nospecialize(e)) = Expr(head(e))

include("util.jl")
include("expr.jl")
include("macroval.jl")
include("parse.jl")
include("kvenum.jl")
include("enum_symbol.jl")

end
