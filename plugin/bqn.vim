function! EvalBQNWrapper() range
    return luaeval('require("bqn").evalBQN(_A[1], _A[2], true)', [a:firstline, a:lastline])
endfunction

command! -range EvalBQNRange <line1>,<line2>call EvalBQNWrapper()
command! EvalBQNFile :lua require("bqn").evalBQN(1, -1, false)
