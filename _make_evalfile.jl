function make_evalfile(name, args::Vararg{Any,N} where N)
    args = [string(a) for a in args]
    return quote
        let name = $(esc(name))
            evalfile("src/$(name).jl", $(args))
        end
    end
end

function macro_make_evalfile(name::Symbol)
    namestr = string(name)
    return quote
        export @$(esc(name))
        macro $(esc(name))(args::Vararg{Any,N} where N)
            let name = $(esc(namestr))
                make_evalfile("$(name)", args...)
            end
        end
    end
end
macro_make_evalfile(name::QuoteNode) = macro_make_evalfile(name.value)

export @make_evalfile
macro make_evalfile(name)
    macro_make_evalfile(name)
end
