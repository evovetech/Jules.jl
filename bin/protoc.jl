#!/usr/bin/env julia

using ProtoBuf

BINDIR = dirname(@__FILE__)
PROTODIR = abspath(joinpath(BINDIR, "../src/Proto"))
SRCDIR = joinpath(PROTODIR, "src")

function main(args::Vector{String})
    args = [
        "-I=$(SRCDIR)",
        # "-I=ProtoBuf/gen",
        "--julia_out=$(PROTODIR)"
    ]
    for file in readdir(SRCDIR)
        if endswith(file, ".proto")
            path = joinpath(SRCDIR, file)
            push!(args, path)
        end
    end
    cmd = ProtoBuf.protoc(`$(args)`)
    run(cmd)
end

cd(BINDIR)
println("BINDIR=$(BINDIR)")
main(ARGS)
