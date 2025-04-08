local U = {}

function U.is_minimum_version(major, minor, patch)
    local version = vim.version()
    return major <= version.major and minor <= version.minor and patch <= version.patch
end

local function is_valid(buf_num)
    if not buf_num or buf_num < 1 then
        return false
    end
    local exists = vim.api.nvim_buf_is_valid(buf_num)
    return vim.bo[buf_num].buflisted and exists
end

function U.get_valid_buffers()
    local buf_nums = vim.api.nvim_list_bufs()
    local ids = {}
    for _, buf in ipairs(buf_nums) do
        if is_valid(buf) then
            ids[#ids + 1] = buf
        end
    end
    return ids
end

function U.get_buffer_names(buf_nums)
    local buf_names = {}
    for _, buf in pairs(buf_nums) do
        if vim.api.nvim_buf_is_valid(buf) then
            buf_names[#buf_names + 1] = vim.api.nvim_buf_get_name(buf)
        end
    end
    return buf_names
end

function U.open_bufs_if_closed(buf_names)
	for _, buf_name in pairs(buf_names) do
		local buf_nums = vim.api.nvim_list_bufs()
		local buf_is_open = false

		for _, buf_num in pairs(buf_nums) do
			local open_buf = vim.api.nvim_buf_get_name(buf_num)
			if buf_name ~= "" and buf_name == open_buf then
				buf_is_open = true
			end
			if buf_is_open then
				break
			end
		end

		if not buf_is_open and buf_name ~= "" then
			vim.api.nvim_command("badd " .. buf_name)
			local buf = vim.fn.bufnr(buf_name)
			vim.api.nvim_buf_set_option(buf, "buflisted", false)
		end
	end
end

function U.get_buffer_ids(buf_names)
    U.open_bufs_if_closed(buf_names)
    local buf_ids = {}
    local buf_nums = vim.api.nvim_list_bufs()
    for _, buf_name in pairs(buf_names) do
        for _, buf_num in pairs(buf_nums) do
            if buf_name ~= "" and buf_name == vim.api.nvim_buf_get_name(buf_num) then
                buf_ids[#buf_ids + 1] = buf_num
            end
        end
    end
    return buf_ids
end

return U
