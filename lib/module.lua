local core = require('core')

local Module = core.Object:extend()

function Module:initialize(main, package, is_builtin, is_stdlib)
  self.main = main
  self.package = package
  self.is_builtin = is_builtin or false
  self.is_stdlib = is_stdlib or false
end

return Module
