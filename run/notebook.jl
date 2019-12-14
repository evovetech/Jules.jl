using IJulia

const NOTES_DIR = joinpath(@__DIR__(), "..", "notebooks")

function main(args...)
    jupyterlab(; dir=NOTES_DIR, detached=true)
end

main(ARGS)
