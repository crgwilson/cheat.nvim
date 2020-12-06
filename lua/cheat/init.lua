local query = require("cheat.query")

local cheat = {}

local currentFileType = vim.api.nvim_buf_get_option(0, "filetype")

function cheat.cheat()
  local queryWindow = query.newQuery(currentFileType)
end

return cheat
