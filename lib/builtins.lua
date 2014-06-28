local table = require('table')
local Module = require('./module')

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

-- builtin modules; from luvit_init.c
local builtins = Set({
  '_tls',
  '_crypto',
  'yajl',
  '_debug',
  'os_binding',
  'http_parser',
  'uv_native',
  'env',
  'constants',
  'zlib_native',
})


return function(name)
  if builtins[name] then
    return Module:new(nil, nil, true, false)
  end
  return nil
end
