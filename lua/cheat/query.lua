local window = require("cheat.window")

local query = {}
local currentFileType = nil
local queryWindowConfig = {
  ["padding"] = {
    ["width"] = 30,
    ["height"] = 45
  },
  ["mappings"] = {
    ["<cr>"] = "'cheat.query'.runQuery()",
    ["<esc>"] = "'cheat.window'.closeCurrentWindow()"
  }
}

local headerString = nil
local helpString = "Enter your query and press enter:"

local resultWindowConfig = {
  ["padding"] = {
    ["width"] = 10,
    ["height"] = 10
  },
  ["mappings"] = {
    ["<esc>"] = "'cheat.window'.closeCurrentWindow()"
  }
}

function query.setCurrentFileType(ftype)
  currentFileType = ftype
end

function query.setHeaderString()
  headerString = "Query cht.sh for: " .. currentFileType
end

function query.newQueryWindow()
  local queryBuffer = vim.api.nvim_create_buf(false, true)
  local queryWindow = window.newFloatingWindow(queryBuffer, queryWindowConfig)

  local centeredQueryHeader = window.centerInWindow(headerString, window.getWidth(queryWindow))

  vim.api.nvim_buf_set_lines(queryBuffer, 0, -1, false, {centeredQueryHeader, helpString, "", ""})
  vim.api.nvim_win_set_cursor(queryWindow, {4, 0})
  vim.cmd("startinsert")

  return queryWindow
end

function query.newResultsWindow(results)
  local resultsBuffer = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(resultsBuffer, 0, -1, false, results)

  local resultsWindow = window.newFloatingWindow(resultsBuffer, resultWindowConfig)
  return resultsWindow
end

function query.getQuery()
  local currentBuf = vim.api.nvim_get_current_buf()
  local bufLines = vim.api.nvim_buf_get_lines(currentBuf, 0, -1, false)
  for i=#bufLines, 1, -1 do
    local queryLine = bufLines[i]
    if line ~= "" and line ~= headerString and line ~= helpString then
      return queryLine
    end
  end
end

function query.newQuery(ftype)
  query.setCurrentFileType(ftype)
  query.setHeaderString()

  local queryWindow = query.newQueryWindow()
end


function query.queryCheatsh(queryString)
  -- cht.sh wants all spaces in the query to be replaced with `+`
  local query = string.gsub(queryString, " ", "+")
  local result = vim.api.nvim_call_function("systemlist", {
    "curl -s cht.sh/" .. currentFileType .. "/" .. query
  })
  return result
end

function query.unstyleResult(queryResult)
  -- Remove ANSI styling from the cht.sh response
  for k,v in pairs(queryResult) do
    -- Remove all the ansi escape characters that cht.sh adds
    queryResult[k] = string.gsub(v, "[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "")
  end
  return queryResult
end

function query.runQuery()
  local queryString = query.getQuery()
  local rawQueryResult = query.queryCheatsh(queryString)
  local queryResult = query.unstyleResult(rawQueryResult)

  window.closeCurrentWindow()
  local resultsWindow = query.newResultsWindow(queryResult)
end

return query
