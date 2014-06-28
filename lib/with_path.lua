local path = require('path')
local string = require('string')
local fs = require('fs')
local Module = require('./module')

local function find_abs(absolute_path)
  local try_file = function(filepath)
    if fs.existsSync(filepath) then
      return Module:new(filepath, nil, false, false)
    end
    return nil
  end

  local extension = path.extname(absolute_path)
  if (extension == '.lua' or extension == '.luvit') and try_file(absolute_path) then
    return Module:new(absolute_path, nil, false, false)
  end

  -- not an actual lua file; assume it's an directory and look for package.lua
  -- config file
  local package_path = path.join(absolute_path, 'package.lua')
  if fs.existsSync(package_path) then
    local meta_loader = loadstring(fs.readFileSync(package_path))
    local meta = meta_loader and meta_loader()
    if meta ~= nil then
      local module = Module:new()

      if meta.main and fs.existsSync(meta.main) then
        module.init_path = path.normalize(path.join(absolute_path, meta.main))
      elseif fs.existsSync(path.join(absolute_path, 'init.lua')) then
        module.init_path = path.normalize(path.join(absolute_path, 'init.lua'))
      end

      -- return the module only when there is a valid entry point
      if module.init_path then
        module.package = meta
        return module
      end
    end
  end

  -- not a directory containing package.lua either; try adding .lua and .luvit
  -- extension
  return try_file(absolute_path .. '.lua') or try_file(path.join(absolute_path, 'init.lua'))
  or try_file(absolute_path .. '.lua') or try_file(path.join(absolute_path, 'init.lua'))
end

return function(filepath, dirname)
  -- Luvit lets module paths always use / even on windows
  filepath = string.gsub(filepath, '/', path.sep)

  local absolute_path
  if string.sub(filepath, 1, string.len(path.root)) == path.root then
    absolute_path = path.normalize(filepath)
  elseif string.sub(filepath, 1,1) == '.' then
    absolute_path = path.join(dirname, filepath)
  end

  if absolute_path == nil then
    return nil
  end

  return find_abs(absolute_path)
end
