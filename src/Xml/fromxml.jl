using EzXML

export fromxml

@generated function fromxml(::Type{T}, node::EzXML.Node) where T
    fromxml_impl(T, node)
end

fromxml(::Type{T}, ::Nothing) where T = nothing
fromxml(::Type{AbstractString}, ::Nothing) = ""
fromxml(::Type{VersionNumber}, ::Nothing) = typemin(VersionNumber)
fromxml(::Type{Tuple{Vararg{T}}}, ::Nothing) where T = tuple()

fromxml(::Type{AbstractString}, node::EzXML.Node) = node.content
fromxml(::Type{VersionNumber}, node::EzXML.Node) = VersionNumber(node.content)
function fromxml(::Type{Tuple{Vararg{T}}}, node::EzXML.Node) where T
    values = []
    for elem in elements(node)
        push!(values, fromxml(T, elem))
    end
    tuple(values...)
end

function Base.show(io::IO, node::EzXML.Node)
    print("EzXML.Node{")
    print("type=", node.type, ", ")
    print("name=", node.name, ", ")
    print("path=", node.path, ", ")
    print("children=[")
    i = 0
    for elem in elements(node)
        if i > 0
            print(", ")
        end
        i += 1
        print(elem.name)
    end
    print("]}")
end

function children(name::AbstractString, node::EzXML.Node)
    [elem
        for elem in elements(node)
        if name == elem.name]
end

function firstchild(name::AbstractString, node::EzXML.Node)
    all = children(name, node)
    if length(all) > 0
        all[1]
    else
        nothing
    end
end

function fromxml_impl(::Type{T}, node::Type{EzXML.Node}) where T
    names = fieldnames(T)
    types = T.types

    ex = :( [] )
    for i in eachindex(types)
        fname = names[i]
        fnode = :( firstchild($(string(fname)), node) )

        ftype = types[i]
        ex = :( push!($ex, fromxml($ftype, $fnode)) )
    end
    :( show(node); println(); T($ex...) )
end
