-- handler.lua
-- https://docs.konghq.com/gateway-oss/2.4.x/plugin-development/custom-logic/
local BasePlugin = require "kong.plugins.base_plugin"
local redis = require "resty.redis"
local kong = kong

local function retrieve_credentials()
  -- get val from redis
  local red = redis:new()
  red:set_timeouts(1000, 1000, 1000) -- 1 sec
  local ok, err = red:connect("demo-redis", 6379) -- redis host address in docker network
  if not ok then
    kong.log.inspect("----- my-custom-plugin retrieve_credentials error -----")
    error(err)
  end
  local redis_val = red:hget("ht", "field")
  kong.log.inspect(redis_val)
  return redis_val
end

local CustomHandler = BasePlugin:extend()

CustomHandler.VERSION = "1.0.0"
-- https://docs.konghq.com/gateway-oss/2.4.x/plugin-development/custom-logic/#plugins-execution-order
CustomHandler.PRIORITY = 10

function CustomHandler:new()
  CustomHandler.super.new(self, "my-custom-plugin")
  kong.log.inspect("----- my-custom-plugin new -----")
end

function CustomHandler:access(config)
  -- Executed for every request from a client and before it is being proxied to the upstream service.
  kong.log.inspect("----- my-custom-plugin access -----")
  CustomHandler.super.access(self)
  kong.log.inspect(config)
  local cache_name = kong.request.get_headers()["x-cache-auth"]
  local cache_delete = kong.request.get_headers()["x-del-auth"]
  -- https://docs.konghq.com/enterprise/2.3.x/plugin-development/entities-cache/
  if cache_delete then
    -- delete cache:
    --  Lua memory cache - local to an Nginx worker process
    --  Shared memory cache (SHM) - local to an Nginx node
    kong.cache:invalidate(cache_delete)
    return kong.response.exit(200, {message = "Auth deleted"})
  end

  if cache_name then
    -- get and save cache from redis, then put it to upstream request
    kong.log.inspect("----- my-custom-plugin access cache-----", cache_name)
    -- !!! Retrieves the value from the cache
    local credential, err = kong.cache:get(cache_name, nil, retrieve_credentials, cache_name)
    if err then
      kong.log.err(err)
      return kong.response.exit(500, {message = "Unexpected error"})
    end

    if not credential then
      return kong.response.exit(401, {message = "Invalid credentials"})
    end
    kong.log.inspect(credential)
    kong.service.request.set_header("X-API-Key", credential)
  end

  kong.log.inspect("----- my-custom-plugin access end-----")
end

return CustomHandler
