local M = {}

local core = require("elixir/core")

local function update_winbar()
  local text = core.get_cur_ctx()
  vim.opt.winbar = text
end

local function setup_winbar()
	vim.api.nvim_set_hl(0, "WinBar", { fg = "#000000", bg = "#eeeeee", bold = true, underline = true })

        vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI", "BufEnter", "BufWinEnter"}, {
          callback = update_winbar,
        })
end

local bufferline = require("bufferline")
bufferline.setup {
    options = {
      mode = "tabs",
      separator_style = "thin", -- "slant", "thick", "thin"
      numbers = "none",
      duplicates = false,
      show_duplicate_prefix = false,
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
      show_tab_indicators = false,
      persist_buffer_sort = true,
      enforce_regular_tabs = false,
  }
}

function M.prev()
  vim.cmd('BufferLineCyclePrev')
end

function M.next()
  vim.cmd('BufferLineCycleNext')
end

function M.close()
  vim.cmd('tabclose')
end

function M.new()
    vim.cmd("tabnew")
end

function M.new_in_cur_buf()
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_win_view = vim.fn.winsaveview()
    M.new()
    vim.api.nvim_set_current_buf(cur_buf)
    vim.fn.winrestview(cur_win_view)
end

setup_winbar()

return M
