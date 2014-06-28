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
  if (extension == '.lua' or extension == '.luvit') then
    local module = try_file(absolute_path)
    if module then
      return module
    end
  end

  -- not an actual lua file; assume it's an directory and look for package.lua
  -- config file
  local package_path = path.join(absolute_path, 'package.lua')
  if fs.existsSync(package_path) then
    local meta_loader = loadstring(fs.readFileSync(package_path))
    local success, meta
    if meta_loader then
      success, meta = pcall(meta_loader)
      if not success then
        meta = nil
      end
    end
    if meta ~= nil then
      local module = Module:new()

      if meta.main and fs.existsSync(meta.main) then
        module.main = path.normalize(path.join(absolute_path, meta.main))
      elseif fs.existsSync(path.join(absolute_path, 'init.lua')) then
        module.main = path.normalize(path.join(absolute_path, 'init.lua'))
      end

      -- return the module only when there is a valid entry point
      if module.main then
        module.package = meta
        return module
      end
    end
  end

  -- not a directory containing package.lua either; try adding .lua and .luvit
  -- extension
  return try_file(absolute_path .. '.lua') or try_file(path.join(absolute_path, 'init.lua'))
  or try_file(absolute_path .. '.luvit') or try_file(path.join(absolute_path, 'init.luvit'))
end

-- this function treats `filepath` as either an absolute or a relative path to
-- the actual module. The path can be either a module directory, or an actual
-- lua file. If it's an actual lua file, it can be either complete lua file
-- location including the '.lua' extension or just the module name.
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
