function! EvalBQNTillLine()
    return luaeval(
          \ 'require("bqn").evalBQN(0, _A[1], true)',
          \ [line(".")])
endfunction

function! EvalBQNRange() range
    return luaeval(
          \ 'require("bqn").evalBQN(_A[1] - 1, _A[2], true)',
          \ [a:firstline, a:lastline])
endfunction

function! ClearBQNAfterLine()
    return luaeval(
          \ 'require("bqn").clearBQN(_A[1] - 1, -1)',
          \ [line(".")])
endfunction

function! ClearBQNRange()
    return luaeval(
          \ 'require("bqn").clearBQN(_A[1] - 1, _A[2])',
          \ [a:firstline, a:lastline])
endfunction

hi link bqnoutok Comment
hi link bqnouterr Error

command! EvalBQNTillLine call EvalBQNTillLine()
command! -range EvalBQNRange <line1>,<line2>call EvalBQNRange()
command! EvalBQNFile :lua require("bqn").evalBQN(0, -1, true)

command! ClearBQNAfterLine call ClearBQNAfterLine()
command! -range ClearBQNRange <line1>,<line2>call ClearBQNRange()
command! ClearBQNFile :lua require("bqn").clearBQN(0, -1)
