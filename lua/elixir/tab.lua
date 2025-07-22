local M = {}

local bufferline = require("bufferline")
bufferline.setup {
    options = {
      mode = "tabs",
      separator_style = "thin", -- "slant", "thick", "thin"
      numbers = "none",
      duplicates = false,
      close_command = function(n)
        vim.cmd("tabclose " .. n)
      end,
      --right_mouse_command = "bdelete! %d",
      --left_mouse_command = "buffer %d",
      indicator = {
        style = "underline",
      },
      buffer_close_icon = "",
      modified_icon = "●",
      close_icon = "",
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = true,
      show_tab_indicators = true,
      persist_buffer_sort = true,
      enforce_regular_tabs = false,
  }
}

function M.close()
  vim.cmd('tabclose')
end

function M.prev()
  vim.cmd('BufferLineCyclePrev')
end

function M.next()
  vim.cmd('BufferLineCycleNext')
end

return M
