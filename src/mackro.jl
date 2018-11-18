using Jules.Macros

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

println(">>>")
for arg in ARGS
    println("  arg=$(arg)")
end
println("<<<")
