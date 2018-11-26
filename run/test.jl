
macro echo(args...)
    expr = Expr(:block)
    for arg in args
        show(arg)
        println()
        push!(expr.args, arg)
    end
    esc(expr)
end

macro config(settings::Bool=false)
    println("settings=$settings")
    nothing
end

function main(args::Vector{String})
    @show begin
        print("args: ")
        show(args)
        println()
        2
    end
end

main(ARGS)
