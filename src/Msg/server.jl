
struct Server
    ctx::Context
    frontend::Socket
    backend::Socket

    function Server(ctx=context())
        frontend = Socket(ctx, ROUTER)
        bind(frontend, FRONTEND_ADDR)
        backend = Socket(ctx, DEALER)
        bind(backend, BACKEND_ADDR)
        new(ctx, frontend, backend)
    end
end
