local driver = require 'mongo'
require "t"

local client = assert(driver.Client('mongodb://mongodb'))
local coll = assert(client:getCollection('test', 'test'))
local cur = assert(coll:find({}))
local mt = debug.getmetatable(cur)

if type(mt.__iter)=='nil' then
  mt.__iter = function(cursor, handler)
    return function()
      return cursor:value(handler)
    end
  end
end

if type(mt.__call)=='nil' then
  mt.__call = function(cursor, handler)
    local it = function()
      return cursor:value(handler)
    end
    return it()
  end
end
