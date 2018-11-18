using Jules.Macros

@parse function sayman(arg1, arg2)::String
    "arg1=$(arg1), arg2=$(arg2)"
end

println(">>>")
for arg in ARGS
    println("  arg=$(arg)")
end
println("<<<")
