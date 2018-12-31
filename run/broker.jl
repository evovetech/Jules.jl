using Jules.Msg
using ZMQ

function start_broker(args...)
    ctx=Context(1)
    xpub=Socket(ctx, XPUB)
    xsub=Socket(ctx, XSUB)

    ZMQ.bind(xsub, "tcp://127.0.0.1:$(BROKER_SUB_PORT)")
    ZMQ.bind(xpub, "tcp://127.0.0.1:$(BROKER_PUB_PORT)")

    ccall((:zmq_proxy, :libzmq), Cint,  (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}), xsub.data, xpub.data, C_NULL)
#    proxy(xsub, xpub)

    # control never comes here
    ZMQ.close(xpub)
    ZMQ.close(xsub)
    ZMQ.close(ctx)
end

start_broker(ARGS)
