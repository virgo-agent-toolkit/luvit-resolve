local path = require('path')
local with_path = require('./with_path')

local modules_paths = { 'modules', 'node_modules' }

return function(filepath, dirname)
  local dir = dirname .. path.sep
  repeat
    for _, bundled_path in ipairs(modules_paths) do
      local full_path = path.join(dir, bundled_path, filepath)
      local module = with_path(full_path, dirname)
      if module then
        return module
      end
    end
    dir = path.dirname(dir)
  until dir == '.'
  return nil
end
