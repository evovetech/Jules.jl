module Cluster

using Base:
    julia_cmd

using Distributed
import Distributed:
    launch,
    manage,
    write_cookie

export
    Manager,
    addprocs

struct Manager <: ClusterManager
    np::Integer
end

function addprocs(np::Integer; kwargs...)
    Distributed.addprocs(Manager(np); kwargs...)
end

function launch(manager::Manager, params::Dict, launched::Array, c::Condition)
    dir = params[:dir]
    exename = params[:exename]
    exeflags = params[:exeflags]
    bind_to = `127.0.0.1`

    for i in 1:manager.np
        cmd = `$(julia_cmd(exename)) $exeflags --bind-to $bind_to --worker`
        io = open(detach(setenv(cmd, dir=dir)), "r+")
        write_cookie(io)

        wconfig = WorkerConfig()
        wconfig.process = io
        wconfig.io = io.out
        wconfig.enable_threaded_blas = params[:enable_threaded_blas]
        push!(launched, wconfig)

        notify(c)
    end
end

function manage(manager::Manager, id::Integer, config::WorkerConfig, op::Symbol)
    println("manage[$id]->$op")
    if op == :interrupt
        println("manage[$id]->kill()")
        kill(config.process, 2)
    end
end

end
