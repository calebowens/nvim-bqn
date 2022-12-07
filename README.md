# nvim-bqn

Use Neovim as a BQN repl.

## Installation

Use your favourite plugin manager (or install manually). My plugin manager of choice is [vim-plug](https://github.com/junegunn/vim-plug).
```
call plug#begin('~/.config/nvim/plugged')
Plug 'git@git.sr.ht:~detegr/nvim-bqn'
call plug#end
```

## Configuration

For now, the plugin expects [CBQN](https://github.com/Dzaima/CBQN) as the interpreter to run. The inner workings of the plugin
call CBQN with `-p` flag.

By default, the plugin expects to find CBQN from path with a executable called `BQN`. This can be changed by
pointing a global variable `g:nvim_bqn` to a different executable.

## Default keybinds

By default, enter evaluates a the file from the beginning to the line that the cursor is on. A selection (range) can be evaluated with enter too, and the range evaluation will only contain the lines that are in the range.

- `<leader>bf` will evaluate every line of the file.
- `<leader>bc` will remove the inline results from the cursor to the end of the file
- `<leader>bc` with a range will remove the inline results within that range
- `<leader>bC` will remove the inline results from the whole file
- `<leader>be` will run expression explainer for a line. Note that the explainer has only the context of the single line and variables may be uninitialized because of it.

## File extensions are not detected and syntax highlighting is missing!

This plugin only provides the REPL-like functionality within the editor. For file extensions, syntax highlighting and keyboard maps, use the plugin from [mlochbaum/BQN](https://github.com/mlochbaum/BQN/tree/master/editors/vim).

## Demo

[![demo](https://asciinema.org/a/5Mj03OEez31CtY2817tDfHMm3.svg)](https://asciinema.org/a/5Mj03OEez31CtY2817tDfHMm3)

## Bugs/caveats

Due to Neovim's [bug](https://github.com/neovim/neovim/issues/16500), the last line of the buffer is problematic. The plugin works around this by moving the last line to the center of the window when that is evaluated. However, it is possible to navigate the editor so that the last line of the buffer has an evaluation result below it and the last line of the buffer is on the last line of the window. In this case, due to the bug, the line is not rendered properly.

Reading an evaluation result that spans below the bottom of the window can be tricky. The Vim scrolling movements `<C-E>` and `<C-Y>` are helpful in such situation.
