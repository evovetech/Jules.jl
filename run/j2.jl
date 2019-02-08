#!/usr/bin/env julia

using Jules: withcontext
using Jules.Play: @m, @show_expr

function main(args::Array{String,1}; d="kwd")
    print("args: ")
    for i in eachindex(args)
        if i > 1
            print(", ")
        end
        withcontext("a$(i)=$(args[i])")
    end
    println()
end

@show_expr begin

    macro mhomie(expr)
        println("mhomie=$(expr)")
        return expr
    end

    @mhomie function homie()
        return "homie"
    end
end

@show_expr begin
    @mhomie function homie2(name::String)
        return "homie"
    end
end

@show_expr:,
function sayman(say::String)
    println("sayman")
end

v = v"1.3.4"
r = r"23"
println("main >>>")
# main(ARGS)
_main = Expr(:call, :main, :ARGS)
eval(_main)
println("<<< main")
