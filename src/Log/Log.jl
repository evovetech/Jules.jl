module Log

export indent, showargs

function indent(io::IO)
    level = get(io, :level, 0)
    for i in 1:level
        print(io, "  ")
    end
end

function indent(f::Function, io::IO)
    level = get(io, :level, 0)
    let io = IOContext(io, :level => level + 1)
        return f(io)
    end
end

function showargs(io::IO, args...)
    for (i, arg) in enumerate(args)
        if i > 1
            print(io, ", ")
        end
        println(io)
        show(io, arg)
    end
    println(io)
end

end
