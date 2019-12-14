
function show_page(io::IO, page::PDPage)
    show(obj) = Base.show(io, obj)

    show(page); println("\n====")
    content = pdPageGetContentObjects(page)
    show(content); println("\n====")
#     for obj in content.objs[1:40]
#         show(obj)
#     end
#     dump(content.objs[1:5]); println()
#     text = sprint(pdPageExtractText, page)
#     println(text)
#     contents = pdPageGetContents(page)
#     bufstm = get(contents)
#     buf = read(bufstm)
#     close(bufstm)
#     show(buf); println()
end

function show_contents(io::IO, doc::PDDoc)
    show(obj) = Base.show(io, obj)

    cat = pdDocGetCatalog(doc)
    show(cat); println()

#     outline = pdDocGetOutline(doc)
#     show(outline); println()

#     cosDoc = pdDocGetCosDoc(doc)
#     show(cosDoc); println()
#     info = pdDocGetInfo(doc)
    for page in doc
        show_page(io, page)
    end
end
show_contents(doc::PDDoc) = show_contents(Base.stdout, doc)

# function Base.show(io::IO, objs::Vector)
#     print(io, "[")
#     indent(io) do io::IO
#         for obj in objs
#             println(io)
#             indent(io)
#             show(io, obj)
#         end
#     end
#     println(io)
#     indent(io)
#     print(io, "]")
# end

# function _cos(io::IO, obj)
#     t = TypeInfo(obj)
#     show(io, t)
#     println(io)
# end

# function Base.show(io::IO, obj::CosObject)
#     _cos(io, obj)
# end
# function Base.show(io::IO, obj::PDPageObject)
#     _cos(io, obj)
# end
# function Base.show(io::IO, obj::Union{PDPageMarkedContent,PDPageTextObject})
#     print(io, typeof(obj), " : ")
#     show(io, obj.group)
# end
# function Base.show(io::IO, obj::PDPageElement{T}) where T
#     print(io, "PageElement{", T, "}")
#     show(io, obj.operands)
# end
# function Base.show(io::IO, group::PDPageObjectGroup)
#     print(io, typeof(group), " : ")
#     show(io, group.objs)
# end
# for T in (CosName, CosDict, CosVal)
#     @eval begin
#         Base.show(io::IO, obj::$(T)) = show(io, obj.val)
#     end
# end
