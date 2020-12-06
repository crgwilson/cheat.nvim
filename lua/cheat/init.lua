local currentFileType = vim.api.nvim_buf_get_option(0, "filetype")
local guiStats = vim.api.nvim_list_uis()[1]
local queryBuffer = vim.api.nvim_create_buf(false, true)

local function centerInWindow(str, windowWidth)
  local shift = math.floor(windowWidth / 2) - math.floor(string.len(str) / 2)
  return string.rep(" ", shift) .. str
end

local function calculatePadding(guiSize, padAmount)
  --[[
    guiSize: The actual full size of the current UI. This is the value which will have the
             padValue applied to it as described below.

    padAmount: Represents the percentage value which will be used to size the border around
               the floating window. For example, a padValue of 20 will will result in 20% of
               the full window size.

    Note: Neovim's `nvim_open_win` function expects an int not a float, so the value returned
          by this function will be floored.
  ]]
  local paddingValue = math.floor(guiSize * (padAmount / 100))
  return paddingValue
end

local function setMappings()
  local mappings = {
    ["<cr>"] = "runQuery()"
  }

  for k,v in pairs(mappings) do
    vim.api.nvim_buf_set_keymap(queryBuffer, "n", k, ":lua require'cheat'." .. v .. "<cr>", {
      nowait = true,
      noremap = true,
      silent = true
    })
  end
end

local function createQueryWindow()
  -- TODO: I am 100% certain this whole padding system is all jacked up and needs fixing,
  --       but it works well enough for now.
  local widthPadding = calculatePadding(guiStats.width, 30)
  local heightPadding = calculatePadding(guiStats.height, 30)

  local windowWidth = math.floor(guiStats.width - (widthPadding * 2))
  local windowHeight = math.floor(guiStats.height - (heightPadding * 2))

  local windowHeader = centerInWindow("Need help with your " .. currentFileType .. "?", windowWidth)
  vim.api.nvim_buf_set_option(queryBuffer, "bufhidden", "wipe")
  vim.api.nvim_buf_set_lines(queryBuffer, 0, -1, false, {windowHeader, "", "Enter your query and press enter:", "", ""})

  local queryWindow = vim.api.nvim_open_win(queryBuffer, true, {
    relative = "editor",
    width = windowWidth,
    height = windowHeight,
    col = widthPadding,
    row = heightPadding,
    style="minimal"
  })

  vim.api.nvim_win_set_cursor(queryWindow, {5, 0})

  setMappings()

  return queryWindow
end

local function runQuery()
  print(vim.inspect(vim.api.nvim_buf_get_lines(buf, 5, -1, false)))
end

local function cheat()
  local queryWindow = createQueryWindow()
end

return {
  centerInWindow = centerInWindow,
  calculatePadding = calculatePadding,
  setMappings = setMappings,
  createQueryWindow = createQueryWindow,
  runQuery = runQuery,
  cheat = cheat
}
