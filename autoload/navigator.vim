"======================================================================
"
" navigator.vim - 
"
" Created by skywind on 2023/06/27
" Last Modified: 2023/06/27 21:51:25
"
"======================================================================


"----------------------------------------------------------------------
" default config
"----------------------------------------------------------------------
let s:config_name = {
			\ 'icon_separator': '=>',
			\ 'icon_group': '+',
			\ 'icon_breadcrumb': '>',
			\ 'max_height': 20,
			\ 'min_height': 5,
			\ 'max_width': 60,
			\ 'min_width': 20,
			\ 'bracket': 0,
			\ 'padding': [2, 0, 2, 0],
			\ 'spacing': 3,
			\ 'vertical': 0,
			\ 'position': 'botright',
			\ 'splitmod': '',
			\ 'popup': 0,
			\ 'popup_position': 'bottom',
			\ 'popup_width': '65%',
			\ 'popup_height': '40%',
			\ 'hide_cursor': 0,
			\ }


"----------------------------------------------------------------------
" open and returns key array
"----------------------------------------------------------------------
function! navigator#open(keymap, prefix, ...) abort
	let opts = (a:0 > 0)? deepcopy(a:1) : {}
	for name in keys(s:config_name)
		if !has_key(opts, name)
			let nm = 'navigator_' . name
			if exists('g:' . nm)
				let opts[name] = get(g:, nm, s:config_name[name])
			endif
		endif
	endfor
	let keymap = navigator#config#keymap_expand(a:keymap)
	" let opts.prefix = a:prefix
	let qf = 0
	if navigator#utils#quickfix_check()
		let qf = 1
		if get(opts, 'popup', 0) == 0
			if get(opts, 'vertical') == 0
				call navigator#utils#quickfix_close()
			endif
		endif
	endif
	let hr = navigator#state#open(keymap, opts)
	if qf != 0
	endif
	return hr
endfunc


"----------------------------------------------------------------------
" execute command
"----------------------------------------------------------------------
function! navigator#cmd(keymap, prefix, ...) abort
	let opts = (a:0 > 0)? (a:1) : {}
	let path = navigator#open(a:keymap, a:prefix, opts)
	if path == []
		return 0
	endif
	let hr = navigator#config#visit(a:keymap, path)
	if type(hr) == v:t_list
		let cmd = (len(hr) > 0)? hr[0] : ''
		try
			if cmd =~ '^[a-zA-Z0-9_#]\+(.*)$'
				" echom "cmd1: " . cmd
				exec 'call ' . cmd
			elseif cmd =~ '^<key>'
				let keys = strpart(cmd, 5)
				call feedkeys(keys)
			elseif cmd =~ '^@'
				let keys = strpart(cmd, 1)
				call feedkeys(keys)
			elseif cmd =~ '^<plug>'
				let keys = strpart(cmd, 6)
				call feedkeys("\<plug>" . keys)
			else
				" echom "cmd2: " . cmd
				exec cmd
			endif
		catch
			redraw
			echohl ErrorMsg
			echo v:exception
			echohl None
		endtry
	endif
	return 0
endfunc



