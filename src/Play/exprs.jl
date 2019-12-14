import Base: show
using ..Log

expr_types = quote
    abstract type Node end
    abstract type TypedExpr{T} <: Node end
    struct ValExpr{T} <: TypedExpr{T}
        val::T
    end
    struct SymbolExpr{T} <: TypedExpr{T}
        SymbolExpr(sym::Symbol) = new{sym}()
    end
    struct BasicExpr{T} <: TypedExpr{T}
        args::Vector{<:Node}
    end
    struct InfixExpr{T} <: TypedExpr{T}
        args::Vector{<:Node}
    end
    struct CallExpr{T} <: TypedExpr{T}
        head::TypedExpr{T}
        args::Vector{<:Node}

        function CallExpr(head::TypedExpr{T}, args) where T
            a2 = [arg for arg in args]
            new{T}(head, a2)
        end
    end
    struct QuoteExpr{T} <: TypedExpr{T}
        val::T
    end
end
expr_parse = quote
    function parse_args(args::Vector)
        args = [arg for arg in args if !isa(arg, LineNumberNode)]
        return map(parse, args)
    end
    function parse(::SymbolExpr{T}, args::Node...) where T
        return BasicExpr{T}([args...])
    end
    function parse(::SymbolExpr{:call}, head::TypedExpr{T}, args::Node...) where T
        return CallExpr(head, args)
    end
    parse(expr::Expr) = parse(SymbolExpr(expr.head), parse_args(expr.args)...)
    parse(sym::Symbol) = SymbolExpr(sym)
    parse(node::QuoteNode) = QuoteExpr(node.value)
    parse(arg) = ValExpr(arg)
end
for op = (:(==), :(!==), :(<=), :(>=), :(<), :(>))
    node = QuoteNode(op)
    ex = quote
        function parse(::SymbolExpr{:call}, head::SymbolExpr{$node}, args::Node...)
            return InfixExpr{$node}([args...])
        end
    end
    push!(expr_parse.args, ex.args...)
end
expr_show = quote
    show(io::IO, args::Vector; start='(', stop=')') = begin
        print(io, start)
        if length(args) <= 1
            for arg in args
                show(io, arg)
            end
            print(io, stop)
            return
        end
        if length(args) == 2
            show(io, args[1])
            print(io, ", ")
            show(io, args[2])
            print(io, stop)
            return
        end

        println(io)
        indent(io) do io::IO
            indent(io)
            show(io, args[1])
            for arg in args[2:end]
                println(io, ",")
                indent(io)
                show(io, arg)
            end
            println(io)
        end
        indent(io)
        print(io, stop)
    end
    show_args(io::IO, args::Node...) = begin
        if length(args) == 0
            return
        end
        if length(args) == 1
            show(io, args[1])
            return
        end
        show(io, [args...])
    end
    show_div(io::IO, expr::BasicExpr{T}) where T = begin
        args = expr.args
        if length(args) > 1
            show(io, args[1])
            args = args[2:end]
        end
        print(io, T)
        show_args(io, args...)
    end
    show_block(io::IO, blk::BasicExpr{:block}) = begin
        println(io)
        indent(io) do io::IO
            for arg in blk.args
                indent(io)
                show(io, arg)
                println(io)
            end
        end
        indent(io)
        print(io, "end")
    end
    show_vect(io::IO, args::Vector) = begin
        print(io, "[")
        show_args(io, args...)
        print(io, "]")
    end
    show_infix(io::IO, head::Any, args::Vector) = begin
        show(io, args[1])
        print(io, " ", head, " ")
        show_args(io, args[2:end]...)
    end
    show(io::IO, node::QuoteExpr) = show(io, node.val)
    show(io::IO, expr::ValExpr) = show(io, expr.val)
    show(io::IO, expr::SymbolExpr{T}) where T = print(io, T)
    show(io::IO, expr::BasicExpr{T}) where T = begin
        show(io, T)
        args = [arg for arg in expr.args if !isa(arg, LineNumberNode)]
        show(io, args)
    end
    show(io::IO, expr::BasicExpr{:block}) = begin
        println(io, "begin")
        indent(io) do io::IO
            for arg in expr.args
                indent(io)
                show(io, arg)
                println(io)
            end
        end
        indent(io)
        print(io, "end")
    end
    show(io::IO, expr::InfixExpr{T}) where T = show_infix(io, T, expr.args)
    show(io::IO, expr::CallExpr) = begin
        show(io, expr.head)
        args = expr.args
        kwargs = nothing
        if length(args) > 0 && args[1] isa BasicExpr{:parameters}
            kwargs = args[1].args
            args = args[2:end]
        end
        print(io, '(')
        show(io, args; start = "", stop="")
        if kwargs !== nothing
            print(io, "; ")
            show(io, kwargs; start="", stop="")
        end
        print(io, ')')
    end
    show(io::IO, expr::CallExpr{:(:)}) = begin
        args = expr.args
        if length(args) == 0
            # TODO: not sure
            args = expr.args[:]
            print(io, ":")
            return
        end
        show(io, args[1])
        print(io, ":")
        show_args(io, args[2:end]...)
    end
    show(io::IO, expr::CallExpr{:(!)}) = begin
        print(io, "!")
        show_args(io, expr.args...)
    end
    show(io::IO, expr::BasicExpr{:(::)}) = show_div(io, expr)
    show(io::IO, expr::BasicExpr{:curly}) = begin
        show(io, expr.args[1])
        show(io, expr.args[2:end]; start='{', stop='}')
    end
    show(io::IO, expr::BasicExpr{:where}) = begin
        show(io, expr.args[1])
        print(io, " where ")
        show(io, expr.args[2:end]; start='{', stop='}')
    end
    show(io::IO, expr::BasicExpr{:function}) = begin
        print(io, "function ")
        show(io, expr.args[1])
        show_block(io, expr.args[2])
    end
    show(io::IO, expr::BasicExpr{:.}) = begin
        args = expr.args
        @assert length(args) == 2
        show(io, args[1])
        print(io, ".")
        node = args[2]
        if isa(node, QuoteExpr)
            args[2] = parse(node.val)
        end
        show(io, args[2])
    end
    show(io::IO, expr::BasicExpr{:...}) = begin
        args = expr.args
        @assert length(args) == 1
        show(io, args[1])
        print(io, "...")
    end
    show(io::IO, expr::BasicExpr{:ref}) = begin
        args = expr.args
        @assert length(args) == 2
        show(io, args[1])
        print(io, "[")
        show(io, args[2])
        print(io, "]")
    end
    show(io::IO, expr::BasicExpr{:vect}) = begin
        show_vect(io, expr.args)
    end
    show(io::IO, expr::BasicExpr{:return}) = begin
        print(io, "return ")
        show_args(io, expr.args...)
    end
    show(io::IO, expr::BasicExpr{:do}) = begin
        args = expr.args
        @assert length(args) == 2
        show(io, args[1])
        print(io, " do ")
        show(io, args[2])
    end
    show(io::IO, expr::BasicExpr{:->}) = begin
        args = expr.args
        @assert length(args) == 2
        arg = args[1]
        if isa(arg, BasicExpr{:tuple})
            show_args(io, arg.args...)
            arg = nothing
        end
        if arg !== nothing
            show(io, arg)
        end
        show_block(io, args[2])
    end
    show(io::IO, expr::BasicExpr{:tuple}) = begin
        args = expr.args
        if length(args) > 1
            show(io, args)
            return
        end

        print(io, "(")
        for arg in args
            show(io, arg)
            print(io, ",")
        end
        print(io, ")")
    end
    show(io::IO, expr::BasicExpr{:for}) = begin
        args = expr.args
        print(io, "for ")
        show(io, args[1])
        show_block(io, args[2])
    end
    show(io::IO, expr::BasicExpr{:comprehension}) = begin
        show_vect(io, expr.args)
    end
    show(io::IO, expr::BasicExpr{:generator}) = begin
        args = expr.args
        show(io, args[1])
        print(io, " for ")
        show_args(io, args[2:end]...)
    end
    show(io::IO, expr::BasicExpr{:filter}) = begin
        args = expr.args
        @assert length(args) == 2
        show(io, args[2])
        print(io, " if ")
        show(io, args[1])
    end
    show(io::IO, expr::BasicExpr{:abstract}) = begin
        print(io, "abstract type ")
        show_args(io, expr.args...)
        println(io)
        print(io, "end")
    end
    show(io::IO, expr::BasicExpr{:struct}) = begin
        args = expr.args
        @assert length(args) == 3
        mu = args[1]::ValExpr{Bool}
        if mu.val
            print(io, "mutable ")
        end
        print(io, "struct ")
        show(io, args[2])
        show_block(io, args[3])
    end
    show(io::IO, expr::BasicExpr{:kw}) = begin
        args = expr.args
        @assert length(args) == 2
        show(io, args[1])
        print(io, "=")
        show(io, args[2])
    end
end
for op in (:(<:), :(>:), :(=), :(&&), :(||))
    node = QuoteNode(op)
    ex = quote
        show(io::IO, expr::BasicExpr{$node}) = begin
            if length(expr.args) <= 1
                show_div(io, expr)
                return
            end
            show_infix(io, $node, expr.args)
        end
    end
    push!(expr_show.args, ex.args...)
end

# @p print_expr(expr)
# @p eval(expr)

expr = Expr(:block, expr_types.args..., expr_parse.args..., expr_show.args...)
eval(expr)

export show_exprs

function show_exprs(io::IO)
    blk = parse(expr)
    for arg in blk.args
        show(io, arg)
        print("\n\n")
    end
end
show_exprs() = show_exprs(Base.stdout)
