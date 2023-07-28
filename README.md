# What is it ?

![](https://skywind3000.github.io/images/p/misc/2023/vim-menu2.png)

Vim has got several **whichkey** like plugins for keymap hints and I've tried each of them one by one and found them always lacking in some way. As a result, I've made the decision to create my own plugin, which is similar to whichkey but with some exciting enhancements.

## Features

- Better layout: each column can have different width. Columns with short texts will not occupy a lot of space.
- Fully customizable: separator style and visibility, bracket (around key character) visibility, spacing, padding, highlighting, and position.
- Zero timeout mode and adaptive window size.
- Buffer local keymaps for different file types.
- Unambiguity syntax to define a command or key sequence.
- Runtime keymap generation, items can be decided at runtime.
- Can use popup for vim 8.2+ and floatwin for nvim 0.6.0+
- Legacy Vim compatibility (only requires Vim 7.4.2364).

## Installation

```VimL
Plug 'skywind3000/vim-quickui'
Plug 'skywind3000/vim-quickui-navigator'
```

[vim-quickui](https://github.com/skywind3000/vim-quickui) is required, because it provides unified API to access popup in Vim and floatwin in NVim.

## Quick start

Put this in you `.vimrc`:

```VimL
" initialize global keymap and declare prefix key
let g:navigator = {'prefix':'<tab><tab>'}

" buffer management
let g:navigator.b = {
            \ 'name' : '+buffer' ,
            \ '1' : [':b1'        , 'buffer 1']        ,
            \ '2' : [':b2'        , 'buffer 2']        ,
            \ 'd' : [':bd'        , 'delete-buffer']   ,
            \ 'f' : [':bfirst'    , 'first-buffer']    ,
            \ 'h' : [':Startify'  , 'home-buffer']     ,
            \ 'l' : [':blast'     , 'last-buffer']     ,
            \ 'n' : [':bnext'     , 'next-buffer']     ,
            \ 'p' : [':bprevious' , 'previous-buffer'] ,
            \ '?' : [':Leaderf buffer'   , 'fzf-buffer']      ,
            \ }

" tab management
let g:navigator.t = {
            \ 'name': '+tab',
            \ '1' : ['<key>1gt', 'tab-1'],
            \ '2' : ['<key>2gt', 'tab-2'],
            \ '3' : ['<key>3gt', 'tab-3'],
            \ 'c' : [':tabnew', 'new-tab'],
            \ 'q' : [':tabclose', 'close-current-tab'],
            \ 'n' : [':tabnext', 'next-tab'],
            \ 'p' : [':tabprev', 'previous-tab'],
            \ 'o' : [':tabonly', 'close-all-other-tabs'],
            \ }

" Easymotion
let g:navigator.m = ['<plug>(easymotion-bd-w)', 'easy-motion-bd-w']
let g:navigator.n = ['<plug>(easymotion-s)', 'easy-motion-s']
```

By default, I prefer not to use leader key timeout method to trigger Navigator. Let's assign a dedicated key, hit `<tab>` twice:

```VimL
nnoremap <silent><tab><tab> :Navigator g:navigator<cr>
```

Command `:Navigator` will find the following variable `g:navigator` and read its keymap configuration.

## Buffer local keymaps

Just define a `b:navigator` variable for certain buffer:

```VimL
let g:_navigator_cpp = {...}
let g:_navigator_python = {...}

autocmd FileType c,cpp let b:navigator = g:_navigator_cpp
autocmd FileType python let b:navigator = b:_navigator_python
```

And run `:Navigator` command and replace the original varname `g:navigator` with `*:navigator`

```VimL
nnoremap <silent><tab><tab> :Navigator *:navigator<cr>
```

Different from the previous command, here we have a `*:` before the variable name. After that `:Navigator` will find variables named `navigator` in both global scope and buffer local scope (`g:navigator` and `b:navigator`) and evaluate them, then merge the result into one dictionary.

## Commands

Default command:

```VimL
:Navigator {varname}
```

This command will open navigator window and read keymap from `{varname}`. So if you have your navigator keymap in the variable `g:my_keymap`, the command `:Navigator g:my_keymap` will read keymap from it.

Visual mode command:

```VimL
:NavigatorVisual {varname}
```

Same as `:Navigator` command but dedicated for visual mode, and can be used with `vmap` or `vnoremap`:

```VimL
vnoremap <silent><tab><tab> :NavigatorVisual g:keymap_visual<cr>
```

The `{varname}` in both `:Navigator` and `:NavigatorVisual` is a standard VimScript variable name with a little extension: if the varname starts with a star and a colon (`*:`), navigator will search both global scope (`g:`) and buffer local scope (`g:`) with the same variable name.

## Keybinding

Once Navigator window is open,

![](https://skywind3000.github.io/images/p/misc/2023/vim-menu3.png)

it accepts these keybinding:

| Key | Action |
|-|-|
| `<c-j>` | next page |
| `<c-k>` | previous page |
| `<PageDown>` | next page |
| `<PageUp>` | previous page |
| `<bs>` | return to parent level |
| `<esc>` | exit navigator |

If there are too many items cannot be displayed in one window, they will be splited into different pages. From the left bottom corner, you will see:

    (page 1/1)

It represents the total page number and current page index. 


## Configuration

Initialize an empty keymap configuration:

```vimL
let g:keymap = {'prefix': "<space>"}
```

You can describe the prefix keys like this, but it is optional.

After that you can defined an item:

```VimL
let g:keymap.o = [':tabonly', 'close-other-tabpage']
```

Each item is a list of command and description, where the first element represents the command. For convenience, the command has several forms:

| Prefix | Meaning | Sample |
|-|-|-|
| `:` | Ex command | `:wincmd p` |
| `<key>` | Key sequence | `<key><c-w>p` (this will feed `<c-w>p` to vim) |
| `^[a-zA-Z0-9_#]\+(.*)$` | Function call | `MyFunction()` |
| `<plug>` | Plug trigger | `<plug>(easymotion-bd-w)` |

A group is a subset to hold items and child groups:

```VimL
let g:keymap.w = {
    \ 'name': '+window',
	\ 'p': ['wincmd p', 'jump-previous-window'],
	\ 'h': ['wincmd h', 'jump-left-window'],
	\ 'j': ['wincmd j', 'jump-belowing-window'],
	\ 'k': ['wincmd k', 'jump-aboving-window'],
	\ 'l': ['wincmd l', 'jump-right-window'],
	\ 'x': {
	\       'name': '+management',
	\       'o': ['wincmd o', 'close-other-windows'],
	\   },
	\ }
```

In the "Quick start" section, we defined a `g:navigator` variable to store keymaps and paired with the command:

```VimL
:Navigator g:navigator
```

Here we use another variable `g:keymap` so its command will be:

```VimL
:Navigator g:keymap
```

## Visual mode

...

## Runtime evaluation

Configuration can be generated at runtime by providing a function name like this:

```VimL
function! GenerateSubKeymap() abort
    return {
        \ 'name': '+coding',
        \ 'a': [':echo 1', 'command-a'],
        \ 'b': [':echo 2', 'command-b'],
        \ 'c': [':echo 3', 'command-c'],                
        \ }
endfunc

let keymap.c = '${GenerateSubKeymap()}'
```

The function will be called each time before opening Navigator window, it should returns the latest configuration.

This allows you generate context sensitive keymaps.

## Customize

...

## TODO

- Documentation and vim help file.

## Credit

- [vim-which-key](https://github.com/liuchengxu/vim-which-key)



