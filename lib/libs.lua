local fs = require('fs')
local path = require('path')
local with_path = require('./with_path')
local Module = require('./module')

local libpath = process.execPath:match('^(.*)' .. path.sep .. '[^' ..path.sep.. ']+' ..path.sep.. '[^' ..path.sep.. ']+$') ..path.sep.. 'lib' ..path.sep.. 'luvit' ..path.sep

return function(name)
  local module = with_path(libpath .. name)
  if module then
    module.is_stdlib = true
  end
  return module
end
