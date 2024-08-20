local t = t or require "t"

return {
  token=t.string,
  role=t.string,
  [true] = {
    id=[[token]],
    required=[[token role]],
  }
}