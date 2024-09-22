local t = t or require "t"
local driver = require "mongo"
return t.type ^ driver.type
