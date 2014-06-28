local builtins = require('./builtins')
local libs = require('./libs')
local with_path = require('./with_path')
local modules = require('./modules')

return function(filepath, dirname)
  -- resolve order:
  -- 1. absolute or relative path to the module
  -- 2. builtin module from luvit runtime
  -- 3. standard library from luvit/lib/luvit
  -- 4. look for different "modules/" directories, starting from dirname and
  -- all the way back until root
  return with_path(filepath, dirname) or builtins(filepath) or libs(filepath) or modules(filepath, dirname)
end
