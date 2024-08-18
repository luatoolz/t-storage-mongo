-- using global t to prevent require "t" loop
-- global t should always be defined because of init.d
local t = assert(t)
-- load using full name to prevent t/storage/mongo/init.lua loop
require 't.storage.mongo.cursor'
