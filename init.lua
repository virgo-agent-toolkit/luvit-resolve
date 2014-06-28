local resolve = require('./lib/resolve')

local exports = {}

exports.resolve_package = resolve

exports.resolve = function(filepath, dirname)
  local module = resolve(filepath, dirname)
  if module then
    return module.main
  end
  return nil
end

return exports
