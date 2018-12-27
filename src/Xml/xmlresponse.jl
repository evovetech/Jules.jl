import HTTP

export XmlResponse

struct XmlResponse{T}
    status::Int16
    headers::Dict{String,String}
    body::T

    function XmlResponse{T}(response::HTTP.Response) where T
        headers = Dict(response.headers...)
        doc = parsexml(String(response.body))
        body = fromxml(T, doc.root)
        new(response.status, headers, body)
    end
end
