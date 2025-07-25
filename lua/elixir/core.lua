local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")

local function print_idx(expr)
        local start_row, start_col, end_row, end_col = expr:range()
	local text = string.format("range: (%d, %d) -> (%d, %d)", start_row, start_col, end_row, end_col)
	print(text)
end
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

local function check_node(node_type, child)
        local t = child:type()
        local flag = 0
        local row, col

	if node_type == 1 then
		if t == "function_declarator" then
			row, col = child:range()
			flag = 1
		elseif t == "pointer_declarator" then
			row, col = child:range()
			col = col + 1
			flag = 1
		end
	elseif node_type == 99 then
		--전처리기 보류
	elseif node_type == 2 then
		if t == "array_declarator" or
		t == "init_declarator" then
			row, col = child:range()
			flag = 1
		end
	elseif node_type == 3 then
		if t == "type_identifier" then
			row, col = child:range()
			flag = 1
		end
	end

	return flag, row, col
end

function M.get_cur_ctx()
        local node = ts_utils.get_node_at_cursor()
        local node_
        local node_type = 0
        local text = ""
        local flag, row, col

        while node do
                local t = node:type()

                if t == 'struct_specifier' then
                        node_ = node
                        node_type = 3
		elseif t == 'function_definition' then
                        node_ = node
                        node_type = 1
		elseif t == 'preproc_function_def' then
                        --node_type
		elseif t == 'declaration' then
                        node_ = node
                        node_type = 2
                end

                node = node:parent()
        end
	if node_type == 0 then
		return ""
	elseif node_type == 2 then
		node = node_struct
	end
	node = node_

        local count = node:named_child_count()
        for i = 0, count - 1 do
                local child = node:named_child(i)

		flag, row, col = check_node(node_type, child)
		if (flag == 1) then
			break
		end
        end

        local start_row, start_col, end_row, end_col = node:range()
        local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

        if #lines == 0 then
                return ""
        end

        if node_type == 1 then
                text = get_cur_ctx_name(lines, '{', ' ')
        elseif node_type == 99 then
               -- text = get_cur_ctx_name(lines, ')', ')')
        elseif node_type == 2 then
                text = get_cur_ctx_name(lines, '=', ' ')
        elseif node_type == 3 then
                text = get_cur_ctx_name(lines, '{', ' ')
        end

        return text, row, col
end

return M

