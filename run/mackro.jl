using Jules.Macros

for i in 1:3
    enum = Meta.parse("@enum_wrap$i")
    push!(enum.args, :(ExprType2::UInt8))
    push!(enum.args, :(begin
        $(Symbol(:A, i)) = 0
        $(Symbol(:B, i))
        $(Symbol(:C, i))
    end))
    # show(enum)
    # println()
    eval(enum)
end

@kvenum ExprType3::UInt8 begin
    :unknown    => UnknownExpr3
    :(::)       => TypecastExpr3
    :(=)        => AssignExpr3
    :tuple      => TupleExpr3
    :call       => CallExpr3
    :function   => FunctionExpr3
    :body       => BodyExpr3
    :block      => BlockExpr3
end

println(">>>")
for arg in ARGS
    println("  arg=$(arg)")
end
println("<<<")

#=

function __kvenum(pairs::KvenumPairs)
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
    __exprsymbols = Dict([ (v, k)
        for (k, v) in __exprtypes
    ])
end
=#
