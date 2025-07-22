local M = {}

local function cscope_wrapper(ch, input)
  if input and input ~= "" then
        vim.cmd("Cs find " .. ch .. " " .. input)
  else
        vim.notify("err", vim.log.levels.WARN)
  end
end

function M.symbol()
  vim.ui.input({ prompt = "symbol: " }, function(input)
    cscope_wrapper("s", input)
  end)
end

function M.definition()
  vim.ui.input({ prompt = "Definition: " }, function(input)
    cscope_wrapper("g", input)
  end)
end

return M
