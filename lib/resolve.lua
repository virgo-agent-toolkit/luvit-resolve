local builtins = require('./builtins')
local libs = require('./libs')
local with_path = require('./with_path')
local modules = require('./modules')

return function(filepath, dirname)
  return with_path(filepath, dirname) or builtins(filepath) or libs(filepath) or modules(filepath, dirname)
end
