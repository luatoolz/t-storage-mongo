local driver = require 'mongo'
local t = require "t"
local is = t.is
local normalize = require "t.storage.mongo.normalize"
local records = require "t.storage.mongo.records"
local oid = require "t.storage.mongo.oid"
local json = t.format.json
--local inspect = require 'inspect'

return setmetatable({}, {
  __add = function(self, x)
    if is.json(x) then x=json.decode(x) end
    if is.bulk(x) then return self .. x end
    if is.table.unindexed(x) or getmetatable(x or {}) then
      x._id=oid(x._id)
      return assert(self.__:insert(x)) and 1 or false
    end -- TODO: pack table with metatable
    return 0
  end,
  __call = function(self, ctx) return setmetatable({___=assert(ctx)}, getmetatable(self)) end,
  __concat = function(self, x)
    local rv
    if is.bulk(x) and not is.empty(x) then
      local bulk = self.__:createBulkOperation{ordered = true}
      for it in table.iter(x) do
        if is.json_object(it) then it=json.decode(it) end
        if type(it)=='table' and not is.bulk(it) then
          if it._id then it._id=oid(it._id) end
          bulk:insert(it)
        end
      end
      rv=assert(bulk:execute()) -- t= { "nInserted" : 2, "nMatched" : 0, "nModified" : 0, "nRemoved" : 0, "nUpserted" : 0, "writeErrors" : [  ] }
      if rv then rv=rv:value() end
      return (rv and #rv.writeErrors==0) and (tonumber(rv.nInserted or 0)+tonumber(rv.nUpserted or 0)) or false
    end
    return 0
  end,
--  __div = function(self, o) return self end,
  __index = function(self, id)
    if id=='__' then
      if not self.___ then return nil end
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
    if type(id)=='string' and id:match('^__') then return nil end
    local query
    if type(id)=='number' then return self[{}][id] end
    if is.json_object(id) then id = json.decode(id) end
    if t.type(id)=='mongo.ObjectID' then query = {_id = oid(id)} end
    if is.table_with_id(id) then query = {_id = oid(id._id)} end
    if is.oid(id) then query = {_id = oid(id)} end

    if (not query) and type(id)=='string' and #id>0 and not (id=='' or id=='*') and type(self.___)=='table' and not is.oid(id) then
--      local objs=self.___.objects
      local item=self.___.item
      if type(item)=='table' and (getmetatable(item) or {}).__mod then query=(item % id) end
    end

    if query then query=self.__:findOne(query); return query and query:value() or nil end -- record(self.__:findOne(query), self)

    -- multi records
    if type(id)=='nil' or id=='' or id=='*' or is.table.empty(id) then query={} end
    if (not query) and is.table_no_id(id) or is.table_empty(id) then query = id end
    if (not query) and is.json_object(id) then query = json.decode(id) end
    if query then
      assert(t.type(self) == 't/storage/mongo/collection', string.format('collection.__index: require %s, got %s', 't/storage/mongo/collection', t.type(self)))
      return records(self, query)
    end
    -- TODO: check PRIMARY, UNIQ, INDEX KEYS from object definition
  end,
  __mod = function(self, id)
    local query
    if type(id)=='nil' or id=='' or id=='*' or is.table_empty(id) then query={} end
    if is.json_object(id) then id=json.decode(id) end
    if t.type(id) == 'mongo.ObjectID' then query={_id = id} end
    if (not query) and is.table_with_id(id) then query = {_id = oid(id._id)} end
    if (not query) and is.oid(id) then query = {_id = oid(id)} end
    if  (not query) and type(id) == 'table' and is.oid(id._id) then id._id = oid(id._id) end
    if (not query) and is.table_no_id(id) then query = id end
--    if (not query) and is.json_object(id) then query = json.decode(id) end
--    query=query or {}
--    if query and query._id then query._id=oid(query._id) end
    if (not query) and type(id)=='string' and #id>0 and not (id=='' or id=='*') and type(self.___)=='table' and not is.oid(id) then
      local item=self.___.item
      if type(item)=='table' and (getmetatable(item) or {}).__mod then query=(item % id) end
    end
    return query and self.__:count(query) or 0
  end,
  __name='t/storage/mongo/collection',
  __newindex = function(self, id, x)
    if id == nil then
      if x == nil then return nil end
      if is.json(x) then x = json.decode(x) end
      if is.bulk(x) then return self .. x end
      if is.table.unindexed(x) or getmetatable(x or {}) then return self + x end
    end
    local query
    if type(id)=='nil' or id=='' or id=='*' then query={} end
    if is.json(id) then query = json.decode(id) end
    if t.type(id) == 'mongo.ObjectID' then query={_id=id} end
    if is.table_no_id(id) or is.table_empty(id) then query=id end
    if is.table_with_id(id) then query ={_id=id._id} end
    if is.oid(id) then query={_id=oid(id)} end
    if type(id)=='table' and is.oid(id._id) then query={_id=oid(id._id)} end
    if query then
      if is.null(x) then return self.__:remove(query) end
      if is.json(x) then x = json.decode(x) end
      if is.bulk(x) then error('error: coll.id=bulk()') end
      if is.table.unindexed(x) or getmetatable(x or {}) then
        x._id=nil
-- TODO: pack table with metatable
        normalize(x)
        return assert(self.__:update(query, x, {upsert = true}))
      end
      error(' __newindex wrong argument')
-- TODO: log errors instead of error?
    end
  end,
  __sub=function(self, x)
    local query
    if is.table.empty(x) then query=x end
    if type(x)=='nil' or x=='' or x=='*' or is.table.empty(x) then query={} end
    if is.oid(x) then query = {_id = oid(x)} end
    if t.type(x) == 'mongo.ObjectID' then query = {_id = x} end
    if is.table.unindexed(x) then
      if x._id then query={_id=oid(x._id)} else query=x end
    end
    if is.bulk(x) and not is.empty(x) then
      local bulk = self.__:createBulkOperation{ordered = false}
      for it in table.iter(x) do
        if is.json_object(it) then it=json.decode(it) end
        if type(it)=='table' and not is.bulk(it) then
          if it._id then bulk:remove({_id=oid(it._id)}) end
        end
      end
      local rv=assert(bulk:execute()) -- t= { "nInserted" : 2, "nMatched" : 0, "nModified" : 0, "nRemoved" : 0, "nUpserted" : 0, "writeErrors" : [  ] }
      return rv and #rv:value().writeErrors==0 or false
    end
--    if type(query)~='table' then return true end
    return query and assert(self.__:remove(query)) or nil
  end,
  __tostring=function(self) return type(next(self))~='nil' and assert(self.__):getName() or 't/storage/mongo/collection' end,
  __toboolean=function(self) return tonumber(self)>0 end,
  __tonumber=function(self) return assert(self.__):count({}) or 0 end,
  __unm=function(self) return assert(self.__:drop()) end,
})
