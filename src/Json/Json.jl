#=
Json:
- Julia version:
- Author: layne
- Date: 2019-05-09
=#

module Json

using JSON
import ..Jules: Maybe

const JsonType = Dict{String,Any}

include("fromjson.jl")
include("jsonresponse.jl")

export JsonType

end
