# syntax: proto3
using ProtoBuf
import ProtoBuf.meta

mutable struct Msg <: ProtoType
    name::AbstractString
    Msg(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Msg

export Msg
