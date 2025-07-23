local M = {}

-- 현재 커서 위치의 함수명 추출 (treesitter 기반)
local function get_current_function()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local parsers = require("nvim-treesitter.parsers")

  local bufnr = vim.api.nvim_get_current_buf()
  if not parsers.has_parser() then return "" end

  local node = ts_utils.get_node_at_cursor()
  while node do
    local type = node:type()
    if type == "function" or type == "function_definition" or type:match(".*function.*") then
      local name_node = node:field("name")[1]
      if name_node then
        return vim.treesitter.query.get_node_text(name_node, bufnr)
      end
    end
    node = node:parent()
  end
  return ""
end

-- winbar에 표시
local function update_winbar()
  local exclude_ft = { "NvimTree", "TelescopePrompt", "help", "lazy" }
  local ft = vim.bo.filetype
  for _, f in ipairs(exclude_ft) do
    if ft == f then
      vim.wo.winbar = ""
      return
    end
  end

  local func = get_current_function()
  if func and func ~= "" then
    vim.wo.winbar = " " .. func
  else
    vim.wo.winbar = ""
  end
end

-- autocmd 등록
function M.setup()
  vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "InsertLeave" }, {
    callback = function()
      pcall(update_winbar)
    end,
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
