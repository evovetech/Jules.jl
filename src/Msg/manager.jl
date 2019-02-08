using Base.Sys: CPU_THREADS

mutable struct Manager <: ClusterManager
    np::Int
    ctx::Context
    client_router::Socket
    worker_dealer::Socket
    worker_state::WorkerState
    _initialized::Bool

    function Manager()
        m = new()
        m.np = 0
        m.worker_state = WorkerState()
        m._initialized = false
        return m
    end
end

const _manager = Manager()
manager() = initialize(_manager)

isinitialized(m::Manager) = m._initialized
function initialize(m::Manager)
    m._initialized && return m

    m.ctx = Context()
    m.client_router = Socket(m.ctx, ROUTER)
    m.worker_dealer = Socket(m.ctx, DEALER)
    m._initialized = true
    return m
end


const Workers = Dict{Int, Worker}

mutable struct WorkerState
    max_workers::Int
    workers::Workers
end
WorkerState() = WorkerState(CPU_THREADS, Workers())

function addprocs(m::Manager, np::Int)
    m.np += np
    addprocs(m; np=np, topology=:master_worker)
end
addprocs(np::Int) = addprocs(manager(), np)

function rmprocs(m::Manager, np::Int)
    m.np -= np
    # TODO()
end
rmprocs(np::Int) = rmprocs(manager(), np)

function launch(m::Manager, params::Dict, launched::Array, launch_ntfy::Condition)
    #println("launch $(params[:np])")
    for i in 1:params[:np]
        io, pobj = open(`$(params[:exename]) worker.jl $i $(cluster_cookie())`, "r")

        wconfig = WorkerConfig()
        wconfig.userdata = Dict(:zid=>i, :io=>io)
        push!(launched, wconfig)
        notify(launch_ntfy)
    end
end

function manage(m::Manager, id::Int, config::WorkerConfig, op::Symbol)
    if op === :register
        #TODO
    elseif op === :deregister
        #TODO
    elseif op === :interrupt
        #TODO
    elseif op === :finalize
        #TODO
    end

    println("$(op) worker[$(id)]{ config=$(config) }")
    nothing
end

function connect(m::Manager, pid::Int, config::WorkerConfig)
    #println("connect_m2w")
    if myid() == 1
        zid = config.userdata[:zid]
        config.connect_at = zid # This will be useful in the worker-to-worker connection setup.

        print_worker_stdout(config.userdata[:io], pid)
    else
        #println("connect_w2w")
        zid = config.connect_at
        config.userdata = Dict{Symbol, Any}(:zid=>zid)
    end

    streams = setup_connection(zid, SELF_INITIATED)

    udata = config.userdata
    udata[:streams] = streams

    streams
end

function kill(manager::ZMQCMan, pid::Int, config::WorkerConfig)
    send_data(config.userdata[:zid], CONTROL_MSG, KILL_MSG)
    (r_s, w_s) = config.userdata[:streams]
    close(r_s)
    close(w_s)

    # remove from our map
    delete!(manager.map_zmq_julia, config.userdata[:zid])

    nothing
end


# WORKER
function start_worker(zid, cookie)
    #println("start_worker")
    init_worker(cookie, ZMQCMan())
    init_node(zid)

    while true
        (from_zid, data) = recv_data()

        #println("worker recv data from $from_zid")

        streams = get(manager.map_zmq_julia, from_zid, nothing)
        if streams === nothing
            # First time..
            (r_s, w_s) = setup_connection(from_zid, REMOTE_INITIATED)
            process_messages(r_s, w_s)
        else
            (r_s, w_s, t_r) = streams
        end

        unsafe_write(r_s, pointer(data), length(data))
    end
end
