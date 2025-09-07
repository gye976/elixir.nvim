local M = {}

local builtin = require('telescope.builtin')
local ts_utils = require("nvim-treesitter.ts_utils")

local core = require("elixir/core")
local tab = require("elixir/tab")

-- jump to func
function M.def_in_ctx()
        local text, row, col = core.get_cur_ctx()
        if row and col then
		vim.cmd("normal! m'")
                vim.api.nvim_win_set_cursor(0, { row + 1, col })
        end
end

function M.print_cur_ctx()
	core.print_cur_ctx()
end

function M.def()
    builtin.lsp_definitions()
end

function M.ref()
    builtin.lsp_references()
end

function M.incoming()
    builtin.lsp_incoming_calls()
end

function M.outgoing()
    builtin.lsp_outgoing_calls()
end

function M.def_in_newtab()
    tab.new_in_cur_buf()
    M.def()
end

function M.ref_in_newtab()
    tab.new_in_cur_buf()
    M.ref()
end

function M.incoming_in_newtab()
    tab.new_in_cur_buf()
    M.incoming()
end

function M.outgoing_in_newtab()
    tab.new_in_cur_buf()
    M.outgoing()
end

return M

