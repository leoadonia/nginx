local redis = require("resty.redis")
local request_method = ngx.var.request_method

local args = nil

if "GET" == request_method then
    args = ngx.req.get_uri_args()
elseif "POST" == request_method then
    ngx.req.read_body()
    args = ngx.req.get_post_args()
else
    ngx.header["Content-type"] = "application/json;charset=utf-8"
    local resp = '{"code": "500", "data": {}, "message": "Not Support"}'
    ngx.say(resp)
    ngx.exit(ngx.HTTP_OK)
end

local method = args["method"]
local version = tonumber(args["app_version"])

if not version then
    ngx.header["Content-type"] = "application/json;charset=utf-8"
    local resp = '{"code": "500", "data": {}, "message": "Illegal Argument"}'
    ngx.say(resp)
    ngx.exit(ngx.HTTP_OK)
end

if version < 6 then
    ngx.header["Content-type"] = "application/json;charset=utf-8"
    local resp = '{"code": "500", "data": {}, "message": "版本太低"}'
    ngx.say(resp)
    ngx.exit(ngx.HTTP_OK)
end

if method == "app.product.data" then
    ngx.header["Content-type"] = "application/json;charset=utf-8"
    local resp = '{"code": "500", "data": {}, "message": "方法不存在"}'
    ngx.say(resp)
    ngx.exit(ngx.HTTP_OK)
end

local function close_redis(redis)
    if redis == nil then
        return
    end

    local ok, err = redis:close()
    if not ok then
        ngx.say("error to close redis: ", err)
        ngx.exit(400)
    end
end

-- redis
local ip = "192.168.102.73"
local port = 26379
local nredis = redis:new()
local ok, err = nredis:connect(ip, port)
if not ok then
    ngx.say("error to connect to redis: ", err)
    return ngx.exit(400)
end

-- ip limit
local ip = ngx.var.real_ip
local ok, err = nredis:incr("nginx:access:ip:"..ip)
if not ok then
    ngx.say("error limit ip: ", err)
    close_redis(nredis)
    return ngx.exit(400)
end

nredis:expire("nginx:access:ip:"..ip, "60")

local time, err = nredis:get("nginx:access:ip:"..ip)
if not ok then
    ngx.say("error get ip limit: ", err)
    close_redis(nredis)
    return ngx.exit(400)
end

if tonumber(time) > 10 then
    ngx.header["Content-type"] = "application/json;charset=utf-8"
    local resp = '{"code": "500", "data": {}, "message": "用户名密码错误"}'
    ngx.say(resp)
    close_redis(nredis)
    return ngx.exit(403)
end

-- api limit


ngx.header["Content-type"] = "application/json;charset=utf-8"
local resp = '{"code": "200", "data": {"hello world"}, "message": "Success"}'
ngx.say(resp)
ngx.exit(ngx.HTTP_OK)
