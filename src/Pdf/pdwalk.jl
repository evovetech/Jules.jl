abstract type PDWalkObj end
struct PDWalkParent{P,C} <: PDWalkObj
    child::C

    function PDWalkParent{P}(child::C) where {P,C}
        new{P,C}(child)
    end
end
struct PDWalkChild{T} <: PDWalkObj
    val::T
end

function PDWalkObj(obj::T) where T
    c = child(obj)
    return c === nothing ?
        PDWalkChild{T}(obj) :
        PDWalkParent{T}(c)
end

get_child(x) = nothing
get_child(x::PDDoc) = collect(x)
get_child(x::PDPage) = pdPageGetContentObjects(x)
get_child(x::PDPageObjectGroup) = x.objs
get_child(x::PDPageElement) = x.operands
get_child(x::PDPageTextObject) = x.group
get_child(x::PDPageMarkedContent) = x.group
get_child(x::PDPageTextRun) = x.elem

map_child(x) = PDWalkObj(x)
map_child(x::Vector) = map(map_child, x)
map_child(::Nothing) = nothing

child(x) = get_child(x) |> map_child

walk_inner(x, inner) = inner(x)
walk_inner(x::Vector, inner) = map(inner, x)

walk(x, inner, outer) = walk(PDWalkObj(x), inner, outer)
walk(obj::PDWalkChild, inner, outer) = outer(obj)
walk(obj::PDWalkParent{P}, inner, outer) where P = begin
    child = walk_inner(obj.child, inner)
    parent = PDWalkParent{P}(child)
    return outer(parent)
end

postwalk(f, x) = walk(x, x -> postwalk(f, x), f)
