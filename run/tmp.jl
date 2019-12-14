import Jules.Play: @t2

@t2 "notes",
function sayman()
end

@t2 "a",
@t2 "b",
function sayman2()
end

@t2 function sayman3()
end

@t2(
@t2[
function sayman4()
end,
@t2 function sayman5()
end
])

function main(args::Vector{String})
    println("main >>>")
    for i in eachindex(args)
        println(" arg$i=$(args[i])")
    end
    println("<<< main")
end

main(ARGS)
