# nvim-bqn

Use Neovim as BQN repl.

## Installation

Use your favourite plugin manager. My manager of choice is [vim-plug](https://github.com/junegunn/vim-plug)
```
call plug#begin('~/.config/nvim/plugged')
Plug 'git@git.sr.ht:~detegr/nvim-bqn'
call plug#end
```

## Configuration

For now, the plugin expects [CBQN](https://github.com/Dzaima/CBQN) as the interpreter to run. The inner workings of the plugin
call CBQN with `-p` or `-e` flag.

By default, the plugin expects to find CBQN from path with a executable called `BQN`. This can be changed by
pointing a global variable `g:nvim_bqn` to a different executable.

## Default keybinds

By default, enter evaluates a line or a range of lines. This is done by calling `CBQN` with `-p` argument, which
pretty prints the result of the last evaluated line in the range.

`C-Space` evaluates the whole file by default. To see any output, you'll need to use `•Out` or `•Show`.

## Demo

[![demo](https://asciinema.org/a/oEvbrZ8nqAhswiSGNuPbRHU6E.svg)](https://asciinema.org/a/oEvbrZ8nqAhswiSGNuPbRHU6E)
