# syntax: proto3
using ProtoBuf
import ProtoBuf.meta

struct __enum_Msg_Kind <: ProtoEnum
    PAYLOAD::Int32
    CONTROL::Int32
    __enum_Msg_Kind() = new(0,1)
end #struct __enum_Msg_Kind
const Msg_Kind = __enum_Msg_Kind()

mutable struct Msg <: ProtoType
    to_id::UInt32
    from_id::UInt32
    kind::Int32
    data::Array{UInt8,1}
    Msg(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #mutable struct Msg

export Msg_Kind, Msg
