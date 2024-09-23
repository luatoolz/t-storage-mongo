# t.storage.mongo: mongodb object interface
MongoDB object interface for `t` library.
```lua
local t = require "t"
local mongo = t.storage.mongo

local c = 'mongodb://srv:27017/secret'  -- standard mongodb connstring format
local conn = mongo(c) or mongo          -- use specific connection or use t.env defaults
local db = conn/'db'                    -- try to change db using same credentials

mongo ^ t.pluggable.objects             -- link storage with pluggable objects

local coll = mongo['coll']              -- get collection from default mongo connection db
coll = db.coll                          -- or get collection from specific db

local oid = mongo.oid                   -- extended mongo.ObjectID
local _id = oid()                       -- generate random oid
_id = oid('6690c3c574d428e23e0493c7')   -- use existing oid

_id == oid('6690c3c574d428e23e0493c7')  -- __eq
tostring(_id)                           -- __tostring

-- single record:
local r = mongo.coll[_id]               -- single record by _id / linked object index field
print(r.field)                          -- print object field
print(r:method(true))                   -- call object method
coll - {_id='XX', a=7}                  -- delete object record (by _id / index field)

coll[nil] = {{a='x', b='y'}, {q=19}}    -- save using __newindex (single object / bulk)
coll + r1                               -- save objects (oid auto created)
coll .. {r1, r2, ...}                   -- save objects using __concat
coll + '[1,2,3,4,5]'                    -- json bulk assign

coll.id = {a=7, b=88}                   -- save new / update existing (oid specified)
coll[{_id=XY, ...}] = {a=8}             -- same
coll[id1] = {_id=id2, a=7, b=88}        -- different _id on the assigned object is zeroed
coll[_id] = '{"name":"Ann", "age":33}'  -- json object assign

-- multiple records:
coll % {name='Helen'}                   -- count items
coll % '{"age":33}'                     -- json query for count
coll - {_id=X, a=9, ...}                -- remove object by id/query
coll - {'_id1...', '_id2...', ...}      -- remove bulk items

local rr = coll[{name='Alex'}]          -- __iter'atable records
print(tonumber(rr))                     -- lua5.1 #rr alternative for records length
print(toboolean(rr))                    -- true for positive tonumber(rr)
-rr                                     -- delete records from db

rr % t.matcher.valid                    -- filter by matcher callable
rr * t.fn.queue_send                    -- map/foreach

for k,v in pairs(coll[{}]) do ...       -- iterate pairs: _id + object (__pairs)
for it in table.iter(coll[{}]) do ...   -- iterate pairs: _id + object (__iter)
```

## t.storage.mongo.connection
Mongo connection string constructor
- mongo connection string accepted:
  - multiple hosts allowed
  - `mongodb+srv://` scheme allowed
  - password field is escaped
  - options as url-like string, no parsing
- object accepted:
  - fields: `prefix`, `db`, `hosts`, `host`, `port`, `user`, `pass`, `options`, `connstring`
  - same fields are computed by `t.storage.mongo.connection` internally
  - fields mapped with env vars, list above
- default connstring: `mongodb://mongodb:27017`

```lua
local connection = t.storage.mongo.connection
local conn = 
  connection('mongodb+srv://myDatabaseUser:D1fficultP%40ssw0rd@server.example.com/db')
  or connection({db='some', host='main.ms.com', user='unpriv', pass='SoME%%@@!!'})
  or connection()

local db = t.storage.mongo(mongo.conn) or t.storage.mongo
```

## ENV
- `MONGO_PREFIX`
- `MONGO_HOST`
- `MONGO_PORT`
- `MONGO_DB`
- `MONGO_USER`
- `MONGO_PASS`
- `MONGO_OPTIONS`
- `MONGO_CONNSTRING`

## depends luarocks
ATTENTION: for lua5.1/alpine/mongo install `https://github.com/luatoolz/lua-mongo` instead of `lua-mongo`!

- `lua-mongo`
- `t`
- `t-env`
- `t-format-json`
- `t-format-bson`

## system depends
alpine:
- `libbson-static`
- `mongo-c-driver-static`

debian:
- `libmongoc-dev`

## test depends
- `busted`
- `luacheck`
