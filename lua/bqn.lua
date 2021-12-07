local ns = vim.api.nvim_create_namespace('bqnout')

local function enumerate(it)
  local idx, v = 0, nil
  return function()
    v, idx = it(), idx + 1
    return v, idx
  end
end

function clearBQN(from, to)
  vim.diagnostic.reset(ns, 0)
  vim.api.nvim_buf_clear_namespace(0, ns, from, to)
  vim.api.nvim_command("redraw!")
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

    local error = nil
    local lines = {}
    for line, lnum in enumerate(output:gmatch("[^\n]+")) do
        if lnum == 1 then
          local message = line:gsub("^Error: (.*)", "%1")
          if message ~= line then
            error = {message=message}
          end
        end
        if error ~= nil and lnum == 2 then
          local lnum = line:gsub("^%(%-p%):(%d+):", "%1")
          error.lnum = tonumber(lnum) + from - 1
        end
        local hl = 'bqnoutok'
        if error ~= nil then hl = 'bqnouterr' end
        table.insert(lines, {{' ' .. line, hl}})
    end
    table.insert(lines, {{' ', 'bqnoutok'}})

    -- Reset and show diagnostics
    vim.diagnostic.reset(ns, 0)
    if error ~= nil and error.lnum ~= nil then
      vim.diagnostic.set(ns, 0, {{
        message=error.message,
        lnum=error.lnum,
        col=0,
        severity=vim.diagnostic.severity.ERROR,
        source='BQN',
      }})
    end

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

    local botline = vim.fn.line("w$")
    if to + #lines > botline then
      local cur_line = vim.fn.getpos('.')[2]
      if cur_line == to then
        vim.api.nvim_command('normal zz')
      end
    end
end

return {
    evalBQN = evalBQN,
    clearBQN = clearBQN,
}
