local M = {}

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

function M.get_cur_ctx()
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

return M

