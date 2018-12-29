module Dub

using ..Log
import Cassette
using Cassette:
    @context,
    overdub,
    recurse

export
    Ctx,
    dub

@context Ctx

const Meta = Dict{Symbol, IO}

function dub(args...)
    meta = Meta(:io=>Base.stdout)
    return overdub(Ctx(metadata=meta), args...)
end

function Cassette.overdub(ctx::Ctx, f, args...)
    io = get(ctx.metadata, :io, Base.stdout)
    recurse = Cassette.canrecurse(ctx, f, args...) && !isprint(f)

    _prehook(io, f, args)
    if !recurse
        ret = Cassette.fallback(ctx, f, args...)
        print(io, "--->", typeof(ret))
        println(io)
        return ret
    end

    println(io)
    ret = indent(io) do io::IO
        newctx = Cassette.similarcontext(ctx; metadata=Meta(:io=>io))
        Cassette.recurse(newctx, f, args...)
    end
    indent(io)
    _posthook(io, f, ret)
    println(io)
    ret
end

isprint(f) = f in (print, println)
function _prehook(io::IO, f, args)
    # isprint(f) && return

    indent(io)
    printfunc(io, f, args...)
end
function _posthook(io::IO, f, ret)
    # isprint(f) || print(io, "-->", typeof(ret))
    print(io, "|--->", typeof(ret))
    ret
end

@generated function printfunc(io::IO, f, args...)
    types = []
    for T in args
        push!(types, T)
    end
    types = tuple(types...)
    quote
        print(io, f, $types)
    end
end

end
