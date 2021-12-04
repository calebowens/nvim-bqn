local ns = vim.api.nvim_create_namespace('bqnout')

function clearBQN(from, to)
  vim.api.nvim_buf_clear_namespace(0, ns, from, to)
end

function evalBQN(from, to, pretty)
    if to < 0 then
      to = vim.api.nvim_buf_line_count(0) + to + 1
    end
    -- Compute `to` position by looking back till we find first non-empty line.
    while to > 0 do
      local line = vim.api.nvim_buf_get_lines(0, to - 1, to, true)[1]
      if #line ~= 0 and line:find("^%s*#") == nil then break end
      to = to - 1
    end

    if from > to then
      from = to
    end

    to = math.max(to, 1)
    from = math.max(from, 0)

    local code = vim.api.nvim_buf_get_lines(0, from, to, true)
    local program = ""
    for k, v in ipairs(code) do
        program = program .. v .. "\n"
    end

    -- Escape input for shell
    program = string.gsub(program, '"', '\\"')
    program = string.gsub(program, '`', '\\`')

    local flag = "e"
    if pretty then
        flag = "p"
    end

    local found, bqn = pcall(vim.api.nvim_get_var, "nvim_bqn")
    if not found then
        bqn = "BQN"
    end
    local cmd = bqn .. " -" .. flag .. " \"" .. program .. "\""
    local executable = assert(io.popen(cmd))
    local output = executable:read('*all')

    local lines = {}
    local line_count = 0
    local is_error = nil
    for line in output:gmatch("[^\n]+") do
        if is_error == nil then
          is_error = line:find("^Error:") ~= nil
        end
        local hl = 'bqnoutok'
        if is_error then hl = 'bqnouterr' end
        table.insert(lines, {{' ' .. line, hl}})
        line_count = line_count + 1
    end
    table.insert(lines, {{' ', 'bqnoutok'}})

    -- Compute `cto` (clear to) position by looking forward from `to` till we
    -- find first non-empty line. We do this so we clear all "orphaned" virtual
    -- line blocks (which correspond to already deleted lines).
    local total_lines = vim.api.nvim_buf_line_count(0)
    local cto = to
    while cto < total_lines do
      local line = vim.api.nvim_buf_get_lines(0, cto, cto + 1, true)[1]
      if #line ~= 0 and line:find("^%s*#") == nil then break end
      cto = cto + 1
    end

    vim.api.nvim_buf_clear_namespace(0, ns, to - 1, cto)
    vim.api.nvim_buf_set_extmark(0, ns, to - 1, 0, {
      end_line = to - 1,
      virt_lines=lines
    })
end

return {
    evalBQN = evalBQN,
    clearBQN = clearBQN,
}
