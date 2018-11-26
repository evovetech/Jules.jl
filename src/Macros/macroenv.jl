
struct MacroEnv
    mod::Module
    src::LineNumberNode
end
eval(env::MacroEnv, e) = Core.eval(env.mod, e)

macro macroenv()
    try
        Core.eval(__module__, :(macroenv))
    catch
        newenv = MacroEnv(__module__, __source__)
        Core.eval(__module__, :(macroenv = $(newenv)))
    end
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
