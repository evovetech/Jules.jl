using Jules: Maybe

# struct Line
#     method::AbstractString
#     source::AbstractString
# end
#

const RLINE = r"\s+at\s(.*)$"
const RMETHODLINE = r"(.*)\((.*)\)$"

struct Trace
    method::AbstractString
    line::AbstractString
end

function Trace(s::AbstractString)
    m = match(RMETHODLINE, s)
    @assert m !== nothing
    Trace(m.captures[1], m.captures[2])
end

Base.show(io::IO, trace::Trace) = print(io, trace.method, "(", trace.line, ")")

struct Exception
    msg::String
    cause::Maybe{Exception}
    traces::Tuple{Vararg{Trace}}
end

function Base.show(io::IO, ex::Exception)
    println(io, ex.msg)
    for trace in ex.traces
        println(io, "  -> $trace")
    end
    if ex.cause !== nothing
        show(io, ex.cause)
    end
end


function parse_exception(io::IO, msg::AbstractString)
    cause = nothing
    lines = []
    while !eof(io)
        line = readline(io)
        m = match(RLINE, line)
        if m === nothing
            cause = parse_exception(io, line)
        else
            trace = Trace(m.captures[1])
            push!(lines, trace)
        end
    end
    Exception(msg, cause, tuple(lines...))
end
parse_exception(io::IO) = parse_exception(io, readline(io))
parse_exception(file::AbstractString) = open(file) do io
    parse_exception(io)
end

function main(args::Vector{String})
    @assert length(args) == 1

    ex = parse_exception(args[1])
    println("ex >>>")
    show(ex)
    println("<<< ex")
end

main(ARGS)