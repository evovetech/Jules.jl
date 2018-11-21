using Jules.Macros

#=
@parse function sayman(arg1, arg2)::String
    "arg1=$(arg1), arg2=$(arg2)"
end

@parse "p1",
@parse "p2",
@parse "p3",
function sayman2(args...)::String
    io = IOBuffer()
    print(io, ">>>")
    for (i, arg) in enumerate(args)
        if i > 0
            print(io, ", ")
        end
        println(io)
        print(io, "arg$(i)=", arg)
    end
    println(io, "<<<")
    return String(take!(io))
end
=#

for i in 1:3
    enum = Meta.parse("@enum_wrap$i")
    push!(enum.args, :(ExprType2::UInt8))
    push!(enum.args, :(begin
        $(Symbol(:A, i)) = 0
        $(Symbol(:B, i))
        $(Symbol(:C, i))
    end))
    show(enum)
    println()
    eval(enum)
end

@parse @kvenum ExprType3::UInt8 begin
    :unknown    => UnknownExpr
    :call       => CallExpr
end

@parse Dict(
    :unknown    => UnknownExpr,
    :(::)       => TypecastExpr,
    :(=)        => AssignExpr,
)

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
