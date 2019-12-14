
mutable struct PDIterState{N}
    i::Int
end
PDIterState(doc::PDDoc) = PDIterState{length(doc)}(1)

Base.length(doc::PDDoc) = pdDocGetPageCount(doc)
function Base.iterate(doc::PDDoc, state::PDIterState{N}=PDIterState(doc)) where {N}
    i = state.i
    (i > N) && return nothing
    state.i = i+1
    return pdDocGetPage(doc, i), state
end
