module Dub

using ..Log
import Cassette
using Cassette:
    @context,
    overdub,
    recurse

export
    Ctx,
    dub,
    @dub

@context Ctx

const Meta = Dict{Symbol, IO}
const MetaCtx = Ctx{<:Meta}

function dub(f, args...)
    overdub(Ctx(), f, args...)
end

macro dub(expr)
    ctx = Ctx()
    ex = esc(expr)
    quote
        @Cassette.overdub($ctx, $ex)
    end
end

function Cassette.overdub(ctx::Ctx, f, args...)
    io = Base.stdout
    print(io, f, args)
    newctx = Cassette.similarcontext(ctx; metadata=Meta(:io=>io))
    ret = Cassette.overdub(newctx, f, args...)
    print(io, "-->")
    return ret
end

function Cassette.prehook(ctx::MetaCtx, f, args...)
    io = ctx.metadata[:io]
    println(io)
    indent(io)
    print(io, f, args)
end

function Cassette.overdub(ctx::MetaCtx, f, args...)
    io = ctx.metadata[:io]
    if !Cassette.canrecurse(ctx, f, args...)
        ret = Cassette.fallback(ctx, f, args...)
#         println(io)
        return ret
    end
    
    ret = indent(io) do io::IO
        newctx = Cassette.similarcontext(ctx; metadata=Meta(:io=>io))
        Cassette.recurse(newctx, f, args...)
    end
    println(io)
    indent(io)
    return ret
end

function Cassette.posthook(ctx::MetaCtx, output, f, args...)
    io = ctx.metadata[:io]
#     indent(io)
    print(io, "-->", repr(output))
end

end
