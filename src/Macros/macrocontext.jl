
const Maybe{T} = Union{T,Nothing}

abstract type MacroContext end

struct ChildContext <: MacroContext
    mod::Module
    src::LineNumberNode
end

struct RootContext <: MacroContext
    mod::Module
    stack::Vector{ChildContext}

    RootContext(mod::Module) = new(mod, Vector{ChildContext}())
end

isroot(ctx::MacroContext) = false
isroot(ctx::RootContext) = true

Base.push!(root::RootContext, ctx::ChildContext) = push!(root.stack, ctx)
Base.pop!(root::RootContext) = pop!(root.stack)

function set!(mod::Module, key::Symbol, value)
    println("set!($key=$value)")
    Core.eval(mod, :($key = $value))
end
function get!(f::Function, mod::Module, key::Symbol)
    if Base.isdefined(mod, key)
        value = getproperty(mod, key)
        println("get!($key)=$value")
        value
    else
        set!(mod, key, f())
    end
end

function rootcontext(mod::Module)::RootContext
    get!(mod, :__rootcontext__) do
        RootContext(mod)
    end
end
function curcontext(ctx::RootContext)::MacroContext
    stack = ctx.stack
    length(stack) == 0 ? ctx : stack[end]
end
function curcontext(mod::Module)::MacroContext
    curcontext(rootcontext(mod))
end
function pushcontext!(mod::Module, src::LineNumberNode)
    ctx = ChildContext(mod, src)
    root = rootcontext(mod)
    push!(root, ctx)
    ctx
end
pushcontext!(mod::Module, ctx::ChildContext) = pushcontext!(mod, ctx.src)
pushcontext!(ctx::ChildContext) = pushcontext!(ctx.mod, ctx.src)

function popcontext!(mod::Module)::MacroContext
    root = rootcontext(mod)
    pop!(root)
end
popcontext!(ctx::ChildContext) = popcontext!(ctx.mod)

function withcontext(f::Function, mod::Module, src::LineNumberNode)
    ctx = pushcontext!(mod, src)
    try
        return f(ctx)
    finally
        popcontext!(mod)
    end
end

function macro_pushcontext!(mod::Module, src::LineNumberNode)
    ctx = ChildContext(mod, src)
    esc(quote
        if @isdefined __module__
            if __source__ === $(ctx.src)
                Macros.pushcontext!(__module__, $ctx)
            else
                Macros.macro_pushcontext!(__module__, $(ctx.src))
            end
        else
            Macros.pushcontext!($ctx)
        end
    end)
end

function macro_popcontext!(mod::Module, src::LineNumberNode)
    ctx = ChildContext(mod, src)
    esc(quote
        if @isdefined __module__
            if __source__ === $(ctx.src)
                Macros.popcontext!(__module__)
            else
                Macros.macro_popcontext!(__module__, $(ctx.src))
            end
        else
            Macros.popcontext!($ctx)
        end
    end)
end

macro pushcontext!()
    macro_pushcontext!(__module__, __source__)
end

macro popcontext!()
    macro_popcontext!(__module__, __source__)
end

function (ctx::ChildContext)(f::Function)
    try
        return f(ctx)
    finally
        popcontext!(ctx)
    end
end

#=
esc(quote
    local ctx = Macros.@pushcontext!()
    try
        return $(f)(ctx)
    finally
        Macros.popcontext!(ctx)
    end
end)
=#
#
# @inline function withcontext(f::Function)
#     ctx = @pushcontext!()
#     try
#         return f(ctx)
#     finally
#         popcontext!(ctx)
#     end
# end
#
# macro getcontext1()
#     local f = @pushcontext!(); f() do ctx
#         esc(:($ctx))
#     end
# end
#
# macro getcontext2()
#     local f = @pushcontext!(); f() do ctx
#         esc(quote
#             $ctx, Macros.@getcontext1()
#         end)
#     end
# end
#
# macro getcontext3()
#     @pushcontext!() do ctx
#         esc(quote
#             $ctx, Macros.@getcontext2()
#         end)
#     end
# end
