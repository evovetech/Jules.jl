
forward(f::Function,
        args...;
        kwargs...
) = f(args...; kwargs...)

struct FunctionDef
end
