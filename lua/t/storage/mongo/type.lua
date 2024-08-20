local driver = require 'mongo'
local t = t or require "t"
return t.type ^ driver.type
