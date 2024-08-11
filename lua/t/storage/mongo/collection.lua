local driver = require 'mongo'
local t = require "t"
local is = t.is
local records = require "t.storage.mongo.records"
local oid = t.fn.combined(tostring, string.null, driver.ObjectID)
local json = t.format.json

local function normalize_table(x)
  if type(x)=='table' then
    setmetatable(x, nil)
    if type(x[1])~='nil' then x.__array=true end
    for k,v in pairs(x) do
      if type(v)=='table' then
        normalize_table(v)
      end
    end
  end
  return x
end

return setmetatable({}, {
  __add = function(self, x)
    if type(x)=='number' then return self[{}]+x end
    if is.json(x) then x = json.decode(x) end
    if is.table.unindexed(x) or getmetatable(x or {}) then
-- TODO: pack table with metatable
      assert(self.__):insert(x)
      return self
    end
    if is.bulk(x) then return self .. x end
    return self
  end,
  __call = function(self, ctx) return setmetatable({___=assert(ctx)}, getmetatable(self)) end,
  __concat = function(self, x)
    if is.bulk(x) and not is.empty(x) then
      local bulk = assert(self.__):createBulkOperation{ordered = true}
      for it in table.iter(x) do bulk:insert(it) end
      bulk:execute() -- t= { "nInserted" : 2, "nMatched" : 0, "nModified" : 0, "nRemoved" : 0, "nUpserted" : 0, "writeErrors" : [  ] }
    end
    return self
  end,
--  __div = function(self, o) return self end,
  __index = function(self, id)
    if id=='__' and self.___ then
      local ctx = self.___
      local conn = ctx.conn
      local k = ctx.k
      local db = ctx.db or conn.db
      local client=driver.Client(tostring(conn))
      local rv = db and client:getCollection(db, k) or client:getDefaultDatabase():getCollection(k)
      rawset(self, id, rv)
      return rv
-- TODO: auto reconnect
-- TODO: connection pool
    end
    if type(id)=='nil' then return nil end
    if type(id)=='number' then return self[{}][id] end
    local query
    if is.json_object(id) then query = json.decode(id) end
    if t.type(id) == 'mongo.ObjectID' then query = {_id = id} end
    if is.table_with_id(id) then query = {_id = id._id} end
    if is.oid(id) then query = {_id = oid(id)} end
    if type(id) == 'table' and is.oid(id._id) then id._id = oid(id._id) end
    if query then query=assert(self.__):findOne(query); return query and query:value() or nil end -- record(self.__:findOne(query), self)

    -- multi records
    if id=='' or id=='*' then query={} end
    if (not query) and is.table_no_id(id) or is.table_empty(id) then query = id end
    if (not query) and is.json_object(id) then query = json.decode(id) end
    if query then
      assert(t.type(self) == 't/storage/mongo/collection', string.format('collection.__index: require %s, got %s', 't/storage/mongo/collection', t.type(self)))
      return records(self, query)
    end
    -- TODO: check PRIMARY, UNIQ, INDEX KEYS from object definition
    return nil
  end,
  __mod = function(self, x) return assert(self.__):count(x) end,
  __name='t/storage/mongo/collection',
  __newindex = function(self, id, x)
    if id == nil then
      if x == nil then return nil end
      if is.json(x) then x = json.decode(x) end
      if is.bulk(x) then return self .. x end
      if is.table.unindexed(x) or getmetatable(x or {}) then return self + x end
    end
    local query
    if is.json(id) then query = json.decode(id) end
    if t.type(id) == 'mongo.ObjectID' then query={_id=id} end
    if is.table_no_id(id) or is.table_empty(id) then query=id end
    if is.table_with_id(id) then query ={_id=id._id} end
    if is.oid(id) then query={_id=oid(id)} end
    if type(id)=='table' and is.oid(id._id) then query={_id=oid(id._id)} end
    if query then
      if is.null(x) then assert(self.__):remove(query); return end
      if is.json(x) then x = json.decode(x) end
      if is.bulk(x) then error('error: coll.id=bulk()') end
      if is.table.unindexed(x) or getmetatable(x or {}) then
        x._id=nil
-- TODO: pack table with metatable
        normalize_table(x)
        local ok, err = assert(self.__):update(query, x, {upsert = true})
        if ok~=true then
          error(err)
        end
        return
      end
      error(' __newindex wrong argument')
-- TODO: log errors instead of error?
    end
    return nil
  end,
  __sub = function(self, x)
    if type(x)=='nil' then return self end
    if type(x)=='number' then return self[{}]-x end
    if is.oid(x) then x = {_id = oid(x)} end
    if t.type(x) == 'mongo.ObjectID' then x = {_id = x} end
    if is.table.unindexed(x) then assert(self.__):remove(x); return self end
    if is.bulk(x) then
      local bulk = assert(self.__):createBulkOperation{ordered = false}
      for it in table.iter(x) do bulk:remove(it) end
      bulk:execute()
    end
    return self
  end,
  __tostring=function(self) return assert(self.__):getName() or 't/storage/mongo/collection' end,
  __toboolean=function(self) return tonumber(self)>0 end,
  __tonumber = function(self) return assert(self.__):count({}) or 0 end,
  __unm = function(self) assert(self.__):removeMany({}); return self end,
})
