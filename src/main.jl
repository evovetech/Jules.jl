using Mux, Mustache, Requests, JSON, HttpCommon

get_user_email(req) = get(req[:headers], "X-User-Email", "Unknown")

function jsonapi(f, req)
    username = get_user_email(req)

    if username == nothing
        return error_response()
    end

    headers  = HttpCommon.headers()
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Content-Type"] = "text/json; charset=utf-8"

    params = Dict()
    if haskey(req, :data)
        params = req[:data] |> String |> parsequerystring
    end

    d = Dict()
    try
        d = f(username, params)
    catch ex
        Base.showerror(STDOUT, ex, catch_backtrace())
        rethrow(ex)
    end

    response = Dict(
        :status => 200,
        :headers => headers,
        :body => JSON.json(d)
    )

    return response
end

macro jsonapi(e)
    function_name, arg_username, arg_params = e.args[1].args
    function_body = e.args[2]
    esc(quote
        function $(function_name)(req)
            f = ($arg_username, $arg_params) -> $function_body
            return jsonapi(f, req)
        end
    end)
end

@jsonapi function myeval(username, params)
    dir = "/mnt/juliabox/myapp_runs/$username"
    mkpath(dir)

    codefile = joinpath(dir, "code.jl")
    open(codefile, "w") do f
        write(f, get(params, "code", ""))
    end

    logfile = joinpath(dir, "logs")
    try
        run(pipeline(Cmd(`/opt/julia-0.6/bin/julia $codefile`); stdout=logfile, stderr=logfile))
    end

    return Dict("output"=> readstring(logfile))
end

function myapp(req)
    tpl = Mustache.template_from_file(joinpath(dirname(@__FILE__), "userpage.tpl"))
    username = split(split(get_user_email(req), "@")[1], ".")[1] |> Base.ucfirst
    d = Dict("msg"=>"Hello, $(username)!")

    headers  = HttpCommon.headers()
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Content-Type"] = "text/html; charset=utf-8"

    response = Dict(
        :status => 200,
        :headers => headers,
        :body => render(tpl, d)
    )

    return response
end

@app test = (
  Mux.defaults,
  route("/eval", myeval),
  route("/", myapp),
  Mux.notfound())


@sync serve(test)
