#!/usr/bin/env julia

using PackageCompiler

function main(args...)
    root = abspath(@__DIR__(), "..")
    src = joinpath(root, "src")
    build_dir = joinpath(root, "build")
    jules = joinpath(src, "Jules.jl")
    build_shared_lib(
        jules, "jules";
        init_shared = true,
        builddir = build_dir,
        verbose = true,
        Release = true,
        compiled_modules = "yes"
    )
end

main(ARGS)
