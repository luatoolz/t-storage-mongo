local t = require "t"
local is = t.is
local mongo = require 'mongo'
local meta = require "meta"
local require = meta.require(...)
local oid = t.fn.combined(tostring, string.null, mongo.ObjectID)
local records = require ".records"
local json = t.format.json

local function normalize_table(x)
  if type(x)=='table' then
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
    if is.table.unindexed(x) then
      self.__.coll:insert(x);
      return self
    end
    if is.bulk(x) then return self .. x end
    return self
  end,
  __call = function(self, ctx, k)
    assert(ctx);
    assert(k);
    return setmetatable({__ = ctx}, getmetatable(self)) ^ k
  end,
  __name='t/storage/mongo/collection',
  __tostring = function(self) end,
  __toboolean=function(self) return tonumber(self)>0 end,
  __tonumber = function(self) return (self and self.__ and self.__.coll) and self.__.coll:count({}) or 0 end,
  __pow = function(self, o)
    _ = self.__ ^ o;
    return self
  end,
  __mod = function(self, x) return self.__.coll:count(x) end,
  __unm = function(self)
    self.__.coll:removeMany({})
    return self
  end,
  __sub = function(self, x)
    if type(x)=='number' then return self[{}]-x end
    if is.oid(x) then x = {_id = oid(x)} end
    if t.type(x) == 'mongo.ObjectID' then x = {_id = x} end
    if is.table.unindexed(x) then
      self.__.coll:remove(x)
      return self
    end
    if is.bulk(x) then
      local bulk = self.__.coll:createBulkOperation{ordered = false}
      for it in table.iter(x) do bulk:remove(it) end
      assert(bulk:execute())
    end
    return self
  end,
  __concat = function(self, x)
    if is.bulk(x) and not is.empty(x) then
      local bulk = self.__.coll:createBulkOperation{ordered = true}
      for it in table.iter(x) do bulk:insert(it) end
      assert(bulk:execute()) -- t= { "nInserted" : 2, "nMatched" : 0, "nModified" : 0, "nRemoved" : 0, "nUpserted" : 0, "writeErrors" : [  ] }
    end
    return self
  end,
  __index = function(self, id)
    if type(id)=='nil' then return nil end
    if type(id)=='number' then return self[{}][id] end
    local query
    if id=='' or id=='*' then id={} end
    if is.json_object(id) then query = json.decode(id) end
    if t.type(id) == 'mongo.ObjectID' then query = {_id = id} end
    if is.table_with_id(id) then query = {_id = id._id} end
    if is.oid(id) then query = {_id = oid(id)} end
    if type(id) == 'table' and is.oid(id._id) then id._id = oid(id._id) end
    if query then query=self.__.coll:findOne(query); return query and query:value() or query end -- record(self.__.coll:findOne(query), self)

    -- multi records
    if is.table_no_id(id) or is.table_empty(id) then query = id end
    if is.json_object(id) then query = json.decode(id) end
    if query then return records(self, query) end
    -- TODO: check PRIMARY, UNIQ, INDEX KEYS from object definition
    return nil
  end,
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
      if x == nil then
        self.__.coll:remove(query)
        return
      end
      if is.json(x) then x = json.decode(x) end
      if is.bulk(x) then error('error: coll.id=bulk()') end
      if is.table.unindexed(x) or getmetatable(x or {}) then
        x._id=nil
        normalize_table(x)
        local ok, err = self.__.coll:update(query, x, {upsert = true})
        if ok~=true then
          error(err)
        end
        return
      end
      error(' __newindex wrong argument')
    end
    return nil
  end,
})
