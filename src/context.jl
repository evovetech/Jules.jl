mutable struct Context
    counter::Integer
end

global _current_context = Context(1)

isafunction(f::Expr) =
    f.head === :function || Base.is_short_function_def(f)
isafunction(f) = false

macro pass_context(f)
    @assert isafunction(f)

    def = f.args[1]::Expr
    block = f.args[2]::Expr

    name = def.args[1]
    ctx = def.args[2]
    args = def.args[3:end]

    newdef = Expr(:call, name, args...)
    newblock = Expr(
        :block,
        :( $(ctx) = _current_context ),
        block.args...
    )
    return Expr(:function, newdef, newblock)
end

@pass_context function withcontext(ctx::Context, stuff)
    print("dostuff-$(ctx.counter) -> $stuff")
    ctx.counter += 1
end

@pass_context withcontext(ctx::Context, stuff, stuff2) = withcontext(stuff)
