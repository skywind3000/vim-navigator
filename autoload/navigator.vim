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
	let opts.prefix = prefix
	return navigator#state#open(keymap, opts)
endfunc


"----------------------------------------------------------------------
" execute command
"----------------------------------------------------------------------
function! navigator#choose(keymap, prefix, ...) abort
	let opts = (a:0 > 0)? (a:1) : {}
	let path = navigator#open(a:keymap, a:prefix, opts)
	if path == []
		return 0
	endif
	let hr = navigator#config#visit(a:keymap, path)
	if type(hr) == v:t_list
		let cmd = (len(hr) > 0)? hr[0] : ''
		exec cmd
	endif
	return 0
endfunc



