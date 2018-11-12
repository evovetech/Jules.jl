module Jules

import Random

greet() = print("Hello World!")
greet_alien() = print("Hello ", Random.randstring(8))

_t2(a) = "$(typeof(a))($a),"
function t2(args...)
   print("-->")
   for i in 1:length(args)
       a = args[i]
       print("args[$i]=$(_t2(a))")
   end
   println("<--")
   return args
end
function t2(expr::Expr)
    if expr.head === :tuple
        for a in expr.args
            t2(a)
        end
        return expr
    end
    print("($(expr.head))")
    return t2(expr.args...)
end

macro t2(expr::Expr)
    return t2(expr)
end

end # module
