local buf = nil
local win = nil

local function check_buf()
    if win == nil or not vim.api.nvim_win_is_valid(win) then
        local prev = vim.api.nvim_get_current_win()
        if buf == nil then
            buf = vim.api.nvim_create_buf(false, false)
        end
        vim.api.nvim_buf_set_name(buf, "BQN")
        vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(buf, "swapfile", false)
        vim.api.nvim_buf_set_option(buf, "modeline", false)
        vim.cmd("below 3split")
        vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
        win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_option(win, "wrap", false)
        vim.api.nvim_set_current_win(prev)
    elseif vim.api.nvim_win_is_valid(win) then
        local winid = vim.api.nvim_eval("bufwinid(" .. buf .. ")")
        if winid == -1 then
            local prev = vim.api.nvim_get_current_win()
            vim.cmd("below 3split")
            vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
            win = vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(prev)
        end
    end
end

function evalBQN(from, to, pretty)
    local code = vim.api.nvim_buf_get_lines(0, from - 1, to, true)

    local program = ""
    for k, v in ipairs(code) do
        program = program .. v .. "\n"
    end

    -- Escape input for shell
    program = string.gsub(program, '"', '\\"')
    program = string.gsub(program, '`', '\\`')

    flag = "e"
    if pretty then
        flag = "p"
    end

    local executable = assert(io.popen("BQN -" .. flag .. " \"" .. program .. "\""))
    local output = executable:read('*all')
    executable:close()

    check_buf()

    local lines = {}
    local line_count = 0
    for line in output:gmatch("[^\n]+") do
        table.insert(lines, line)
        line_count = line_count + 1
    end

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    vim.api.nvim_win_set_height(win, line_count)
    vim.api.nvim_win_set_cursor(win, {vim.api.nvim_buf_line_count(buf), 0})
end

return {
    evalBQN = evalBQN,
}
