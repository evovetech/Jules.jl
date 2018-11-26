
struct MacroEnv
    mod::Module
    src::LineNumberNode
    # TODO: key/val
end
eval(env::MacroEnv, e) = Core.eval(env.mod, e)

function getenv!(f::Function, mod::Module, key::Symbol)
    if Base.isdefined(mod, key)
        value = getproperty(mod, key)
        println("getenv!($key)=$value")
        value
    else
        value = f()
        println("setenv!($key=$value)")
        Core.eval(mod, :($key = $value))
    end
end

function macroenv!(mod::Module, src::LineNumberNode)
    getenv!(mod, :macroenv) do
        MacroEnv(mod, src)
    end
end
macroenv!(env::MacroEnv) = macroenv!(env.mod, env.src)

macro macroenv!()
    env = MacroEnv(__module__, __source__)
    esc(quote
        if @isdefined __module__
            Macros.macroenv!(__module__, __source__)
        else
            Macros.macroenv!($env)
        end
    end)
end

macro getenv!()
    @macroenv!()
end

struct Typedef{T}
    name::Symbol
end
gettype(::Type{T}) where {T} = T
gettype(::Typedef{T}) where {T} = T
gettype(obj) = gettype(typeof(obj))

function parsetype(env::MacroEnv, typename::Symbol; basetype::DataType=Int32)
    Typedef{basetype}(typename)
end
function parsetype(env::MacroEnv, T::Expr)
    @assert T.head == :(::)
    typename = T.args[1]
    basetype = eval(env, T.args[2])
    parsetype(env, typename; basetype=basetype)
end
parsetype(env::MacroEnv, T) = throw(ArgumentError("invalid type expression for kvenum $T"))
