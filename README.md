# t.storage.mongo: mongodb object interface
MongoDB object interface for `t` library.
```lua
local t = require "t"
local c = 'mongodb://srv:27017/secret'    -- standard mongodb connstring format
local conn = t.storage.mongo(c)           -- use specific connection
      or t.storage.mongo                  -- or use t.env defaults
local mongo = mongo/'other'               -- change db

mongo ^ t.pluggable.objects               -- link mongo storage with pluggable objects by name
mongo ^ {t.objects, {'any', 'name'}}      -- explicit linking

local coll = mongo['coll']                -- get collection from default mongo connection db
coll = db.coll                            -- or get collection from specific db

-- single record:
local r = mongo.coll.id                   -- single record by id / object index fields
print(r.field)                            -- print object field
print(r:method(true))                     -- call object method
_ = coll - r                              -- delete object record (by _id / index field)

_ = coll + r1 + r2 + ...                  -- save objects (oid auto created)
_ = coll .. {r1, r2, ...}                 -- save objects using __concat
coll[nil] = r                             -- save using __newindex (single object / bulk)

coll.id = {a=7, b=88}                     -- save new / update existing (oid specified)
coll[{_id=XY, ...}] = {a=8}               -- same
coll[id1] = {_id=id2, a=7, b=88}          -- different _id on the assigned object is zeroed

-- multiple records:
coll % {name='masha'}                     -- count query
coll - {_id=X, a=9, ...}                  -- remove object by id/query
coll - {'_id1...', '_id2...', ...}        -- remove bulk items

local rr = coll[{age=33}]                 -- __iter'atable records
print(tonumber(rr))                       -- records len 
-rr                                       -- delete records

rr % t.matcher.valid                      -- filter by matcher callable
rr * t.fn.queue_send                      -- map/foreach

for k,v in pairs(coll[{}]) do ...         -- iterate pairs: _id + object
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
- `lua-mongo`
- `t`
- `t-env`
- `t-format-json`

## system depends
alpine:
- `mongo-c-driver`
- `mongo-c-driver-dev`

debian:
- `libmongoc-dev`

## test depends
- `busted`
- `luacheck`
