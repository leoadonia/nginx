local function close_redis(redis)
    if not redis then
        return
    end

    local ok, err = redis:close()
    if not ok then
        ngx.say("failed to close redis: ", err)
    end
end

local redis = require("resty.redis")

local nredis = redis:new()

local ip = "192.168.102.73"
local port = 26379

local ok, err = nredis:connect(ip, port)
if not ok then
    ngx.say("failed to connect to redis: ", err)
    return close_redis(nredis)
end

ok, err = nredis:set("message", "hello world")
if not ok then
    ngx.say("error to set value into redis: ", err)
    return close_redis(nredis)
end
nredis:expire("message", "600000")

local msg, err = nredis:get("message")
if not msg then
    ngx.say("error to get message from redis: ", err)
    return close_redis(nredis)
end

if msg == ngx.null then
    msg = ''
end

ngx.say("message in redis: ", msg)
close_redis(nredis)
