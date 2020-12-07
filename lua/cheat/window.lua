local window = {}

local guiStats = vim.api.nvim_list_uis()[1]
local guiWidth = guiStats.width
local guiHeight = guiStats.height

function window.closeCurrentWindow()
  vim.api.nvim_win_close(0, false)
end

function window.centerInWindow(str, windowWidth)
  local shift = math.floor(windowWidth / 2) - math.floor(string.len(str) / 2)
  return string.rep(" ", shift) .. str
end

function window.calculatePadding(guiSize, padAmount)
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

function window.setMappings(buf, mappings)
  local modes = {"n", "i"}

  for key,callback in pairs(mappings) do
    for modeCount = 1, #modes do
      vim.api.nvim_buf_set_keymap(
        buf,
        modes[modeCount],
        key,
        "<esc>:lua require" .. callback .. "<cr>",
        {
          nowait = true,
          noremap = true,
          silent = true
        }
      )
    end
  end
end

function window.newFloatingWindow(buf, config)
  -- TODO: I am 100% certain this whole padding system is all jacked up and needs fixing,
  --       but it works well enough for now.
  --
  -- padding - Table containing the pad values for the width and the height
  --
  -- config = {
  --   padding = {
  --     "width": 10,
  --     "height": 10
  --   }
  -- }
  local padding = config["padding"]

  local widthPadding = window.calculatePadding(guiWidth, padding["width"])
  local heightPadding = window.calculatePadding(guiHeight, padding["height"])

  local windowWidth = math.floor(guiWidth - (widthPadding * 2))
  local windowHeight = math.floor(guiHeight - (heightPadding * 2))

  vim.api.nvim_buf_set_option(buf, "bufhidden", "delete")

  local newWindow = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = windowWidth,
    height = windowHeight,
    col = widthPadding,
    row = heightPadding,
    style = "minimal"
  })

  window.setMappings(buf, config["mappings"])

  return newWindow
end

function window.getWidth(win)
  local width = vim.api.nvim_win_get_width(win)
  return width
end

return window
