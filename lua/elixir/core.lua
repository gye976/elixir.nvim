local M = {}

local ts_utils = require("nvim-treesitter.ts_utils")

local function check_lang_is_c_cpp()
	local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
	if lang == 'c' then
		return true
	elseif lang == 'cpp' then
		return true
	end

	return false
end

local function_definition_list = {
	function_declarator = { 0, '{' },
	pointer_declarator = { 1, '{' },
}
local type_definition_list = {
	type_identifier = { 0, '{' },
}
local declaration_list = {
	array_declarator = { 0, '=' },
	init_declarator = { 0, '=' },
	function_declarator = { 0, '{' },
	identifier = { 0, ';' },
}
local struct_specifier_list = {
	type_identifier = { 0, '{' },
}
local enum_specifier_list = {
	enumerator_list = { 0, '{' },
}
local expression_statement_list = {
	call_expression = { 0, '{' },
}
local enum_ctx_type = {
	function_definition = { function_definition_list, 0 },
	type_definition = {type_definition_list, 1},
	declaration = {declaration_list, 1},
	struct_specifier = {struct_specifier_list, 1},
	enum_specifier = {enum_specifier_list, 1},
	expression_statement = {expression_statement_list, 1},
}

local function node_get_root_node(node)
	local node_list = {}

	local n = nil
	local max = 99
        while node do
		local t = node:type()
		if enum_ctx_type[t] and
		enum_ctx_type[t][2] < max then
			n = node
			max = enum_ctx_type[t][2]
		end
                node = node:parent()
        end

	return n
end

local function node_get_ctx_node(node)
	local t = node:type()
        local cnt = node:named_child_count()
	local child, child_t

        for i = 0, cnt - 1 do
                child = node:named_child(i)
		child_t = child:type()
		
		if child_t == nil or
		t == nil then
			return nil
		end

		local list = enum_ctx_type[t][1]
		if list == nil then
			return nil
		end

		local set = list[child_t]
		if set then
			return child, set[1], set[2]	
		end
        end

	return nil
end

local function lines_get_name(lines, delimiter, suffix)
        local text = ""
        for i, line in ipairs(lines) do
                local end_pos
                line = line:gsub("^%s+", "")
                line = line:gsub("\t", " ")
                line = line:gsub("%s+", " ")
		line = line:gsub("[\r\n]+", " ")

                end_pos = string.find(line, delimiter)
                if end_pos then
                        text = text .. string.sub(line, 1, end_pos - 1) .. suffix
                        break
                else
                        text = text .. line
                end
        end

        return text
end

local function node_print_childs(node)
	local t = node:type()
	local count = node:named_child_count()

	local str = "childs:"
	for i = 0, count - 1 do
		local child = node:named_child(i)
		local t = child:type()
		str = str .. t .. ","
	end
	str = str .. "/"

	print(str)
end
function M.print_cur_ctx()
        local node = ts_utils.get_node_at_cursor()
	local t = node:type()

	local str = "cur:" .. t .. " / parents:"

	local p = node:parent()
	while p do
		t = p:type()

		str = str .. t .. ','
		p = p:parent()
	end
	str = str .. ' / root:'

	local root_node = node_get_root_node(node)
	if root_node then
		t = root_node:type()
		str = str .. t .. " / root's childs:"
		local count = root_node:named_child_count()
		str = str .. count
		for i = 0, count - 1 do
			local child = root_node:named_child(i)
			local t = child:type()
			str = str .. t .. ", "
		end
	end

	print(str)
end

local function node_find_compound(n)
	local str = "compound_statement"

	local node = n
	if node == nil then
		return nil
	end

	local t = node:type()
	if t == str then
		return node
	end

	local count = node:named_child_count()
	for i = 0, count - 1 do
		local child = node:named_child(i)
		local t = child:type()

		if t == str then
			return child
		end
	end

	return node_find_compound(node:parent())
end

function M.get_cur_compound()
	if check_lang_is_c_cpp() == false then
		return nil
	end

        local node = ts_utils.get_node_at_cursor()
	if node == nil then
		return nil
	end

	local c = node_find_compound(node)
	if c then
        	local start_row, start_col, end_row, end_col = c:range()
		return start_row, start_col, end_row, end_col
	end
	
	return nil
end

function M.get_cur_ctx()
	if check_lang_is_c_cpp() == false then
		return nil
	end

        local node = ts_utils.get_node_at_cursor()
	if node == nil then
		return nil
	end

	local root_node = node_get_root_node(node)
	if root_node == nil then
		return nil
	end

        local start_row, start_col, end_row, end_col = root_node:range()
        local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

	local ctx, c, delimiter = node_get_ctx_node(root_node)
	if ctx == nil then
		return nil
	end

	local text = lines_get_name(lines, delimiter, ' ')

	local row, col = ctx:range()
	print(ctx:type(), col, c)
	col = col + c
	
	return text, row, col
end

return M

