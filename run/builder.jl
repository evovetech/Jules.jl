using Jules.Builder

macro maven(expr)
    esc(:( show($expr) ))
end

function main(args::Vector{String})
    print("args >>> ")
    @maven args
    println(" <<< args")
    d = dep"evovetech.codegraft:inject-core:0.8.6"
    show(d); println()
    resolve(jcenter(), d)
end

main(ARGS)
