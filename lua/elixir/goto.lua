local M = {}

local builtin = require('telescope.builtin')

function M.definition()
    vim.lsp.buf.definition()
end

function M.references()
    builtin.lsp_references()
end

function M.incoming()
    builtin.lsp_incoming_calls()
end

function M.outgoing()
    builtin.lsp_outgoing_calls()
end

local function newtab_in_current_buf()
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_win_view = vim.fn.winsaveview()
    vim.cmd("tab new")
    vim.api.nvim_set_current_buf(cur_buf)
    vim.fn.winrestview(cur_win_view)
end

function M.definition_in_newtab()
    newtab_in_current_buf()
    M.definition()
end

function M.references_in_newtab()
    newtab_in_current_buf()
    M.references()
end

function M.incoming_in_newtab()
    newtab_in_current_buf()
    M.incoming()
end

function M.outgoing_in_newtab()
    newtab_in_current_buf()
    M.outgoing()
end

return M

