# t.storage.mongo: mongodb object interface
MongoDB object interface for `t` library.
```lua
local t = require "t"
local mongo = t.storage.mongo        -- IT WORKS with env defaults, alt above
local db = mongo / 'dbname'     -- db selection

mongo ^ t.any.objects.loader    -- link current db with loader, coll == object name
mongo ^ {l1, l2, l3}            -- accept multiple loaders

local coll = mongo['coll']      -- get collection (auto typed after linking) using default db
coll = db.coll                  -- or use specific db

-- single record:
local r = mongo.coll.id         -- single record by id or unique fields defined for object

print(r.field)                  -- print record field
print(r:method(true))           -- call some object method
-r                              -- delete record

_ = coll + r1 + r2 + ...        -- save objects (oid auto created)
coll[nil] = r                   -- same with __newindex

coll.id = r                     -- save (oid specified)
coll[r] = r                     -- similar

coll[r]={...}                   -- update

-- multiple records:
coll % {...}                    -- count query
coll - {...}                    -- remove(query) or bulk remove array items

local rr = coll[{...}]          -- typed array of linked objects
print(#rr)                      -- print records array len 

_ = coll .. arr1 .. arr2        -- save objects (t.array of objects)

-rr                             -- delete array

rr % t.matcher.valid            -- filter by matcher callable
rr * t.fn.queue_send            -- map/foreach
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
- otherwise default connection is tried: `mongodb://mongodb:27017`

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

## system depends
alpine:
- `mongo-c-driver`
- `mongo-c-driver-dev`

debian:
- `libmongoc-dev`

## test depends
- `busted`
- `luacheck`
