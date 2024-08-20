local t = t or require "t"
return require("meta").loader(...) * t.object(t.definer):definer()