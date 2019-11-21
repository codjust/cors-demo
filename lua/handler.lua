local _M = {}

function _M.read_file(path)
    local contents
    local file = io.open(path, "rb")
    if file then
        contents = file:read("*all")
        file:close()
    end
    return contents
end


function _M.init_cors_config(config)
    if not config then 
        ngx.log(ngx.ERR, "miss cors config")
        os.exit(1)
    end

    local cors = require('lib.resty.cors')
    local allow_hosts = config.allow_hosts
    if allow_hosts then 
        for _, host in ipairs(allow_hosts) do
            cors.allow_host(host)
        end
    end

    local allow_methods = config.allow_methods
    if allow_methods then 
        for _, method in ipairs(allow_methods) do
            cors.allow_method(method)
        end
    end

    local allow_headers = config.allow_headers
    if allow_headers then 
        for _, header in ipairs(allow_headers) do
            cors.allow_header(header)
        end
    end

    local expose_headers = config.expose_headers
    if expose_headers then 
        for _, header in ipairs(expose_headers) do
            cors.expose_header(header)
        end
    end

    local max_age = config.max_age
    if max_age then 
        cors.max_age(max_age)       
    end

    local allow_credentials = config.allow_credentials
    if allow_credentials then 
        cors.allow_credentials(allow_credentials)   
    end
end


function _M.access()
    local request_headers = ngx.req.get_headers()
    local request_method =  ngx.req.get_method()

    -- not option request
    if request_method ~= "OPTIONS" then
        return
    end

    -- not cors request
    if not request_headers['Origin'] or not request_headers["Access-Control-Request-Method"] then
        return
   end

   ngx.exit(204)
end


function _M.header_filter()
    -- implanted headers when response
    local cors = require('lib.resty.cors')
    cors.run()
end


return _M