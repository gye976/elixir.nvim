local M = {}

local builtin = require('telescope.builtin')
local ts_utils = require("nvim-treesitter.ts_utils")

local function get_cur_ctx_name(lines, search_ch, suffix)
        local text = ""
        for i, line in ipairs(lines) do
                local end_pos
                line = line:gsub("^%s+", "")
                line = line:gsub("\t", " ")
                line = line:gsub("%s+", " ")

                end_pos = string.find(line, search_ch)
                if end_pos then
                        text = text .. string.sub(line, 1, end_pos - 1) .. suffix
                        break
                else
                        text = text .. line
                end
        end

        return text
end

local function get_cur_ctx()
        local expr = ts_utils.get_node_at_cursor()
        local expr_struct
        local expr_type = 0
        local text = ""
        local row, col

        while expr do
                local t = expr:type()

                if t == 'struct_specifier' then
                        expr_struct = expr
                end
                if t == 'function_definition' then
                        expr_type = 0
                        break
                end
                if t == 'preproc_function_def' then
                        expr_type = 1
			break
                end

                expr = expr:parent()
        end

        if not expr then
                if not expr_struct then
                        return ""
                else
                        expr = expr_struct
                end
        end

        local count = expr:named_child_count()
        for i = 0, count - 1 do
                local child = expr:named_child(i)
                local t = child:type()
                if t == "function_declarator" then
                        row, col = child:range()
                        break
                elseif t == "pointer_declarator" then
                        row, col = child:range()
                        col = col + 1
                        break
                end
        end

        local start_row, start_col, end_row, end_col = expr:range()

        local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

        if #lines == 0 then
                return ""
        end

        if expr_type == 0 then
                text = get_cur_ctx_name(lines, '{', ' ')
        elseif expr_type == 1 then
                text = get_cur_ctx_name(lines, ')', ')')
        end

        return text, row, col
end

local function update_winbar()
  local text = get_cur_ctx()
  if text == "" then text = " " end
  vim.opt.winbar = text
end

function M.setup()
	vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI", "BufEnter", "BufWinEnter"}, {
	  callback = update_winbar,
	})
end

-- jump to func
function M.func()
        local text, row, col = get_cur_ctx()
        if row and col then
                vim.api.nvim_win_set_cursor(0, { row + 1, col })
        end
end

function M.definitions()
    builtin.lsp_definitions()
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

function M.definitions_in_newtab()
    newtab_in_current_buf()
    M.definitions()
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

