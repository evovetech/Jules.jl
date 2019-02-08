
struct Worker
    ctx::Context
    work::Socket

    function Worker(ctx=context())
        work = Socket(ctx, DEALER)
        connect(work, BACKEND_ADDR)
        new(ctx, work)
    end
end
