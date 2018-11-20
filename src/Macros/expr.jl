using Base: @_pure_meta

struct ExprVal{T} end
ExprVal(x) = (@_pure_meta; ExprVal{x}())

@enum ExprType::UInt8 begin
    UnknownExpr = 0

    #
    TypecastExpr
    AssignExpr

    #
    TupleExpr
    CallExpr
    FunctionExpr
    BodyExpr
    BlockExpr
end
convert(::ExprVal, e::ExprType) = ExprVal(e)

head(::ExprVal) = :unknown
express(e) = Expr(head(e))

__exprtypes = Dict(
    :unknown    => UnknownExpr,
    :(::)       => TypecastExpr,
    :(=)        => AssignExpr,

    :tuple      => TupleExpr,
    :call       => CallExpr,
    :function   => FunctionExpr,
    :body       => BodyExpr,
    :block      => BlockExpr
)
# flip
__exprsymbols = Dict([
    (v, k) for (k, v) in __exprtypes
])

for (k, v) in __exprtypes
    @eval head(::ExprVal{$(v)}) = $(k)
end

const MaybeExprType = Union{ExprType,Symbol}

function MaybeExprType(symbol::Symbol)
    type = get(__exprtypes, symbol, UnknownExpr)
    if type === UnknownExpr
        return symbol
    end
    type
end
MaybeExprType(expr::Expr) = MaybeExprType(expr.head)

head(symbol::Symbol)::Symbol = symbol
function head(exprtype::ExprType)::Symbol
    get(__exprsymbols, exprtype, :unknown)
end
