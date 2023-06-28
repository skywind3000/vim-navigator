" vim: set ts=4 sw=4 tw=78 noet :
"======================================================================
"
" state.vim - state manager
"
" Created by skywind on 2022/12/24
" Last Modified: 2022/12/24 00:03:21
"
"======================================================================


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
let s:opts = {}
let s:path = []
let s:current = {}
let s:popup = 0
let s:vertical = 0
let s:position = ''
let s:screencx = 0
let s:screency = 0
let s:wincx = 0
let s:wincy = 0
let s:state = -1
let s:exit = 0
let s:prefix = ''


"----------------------------------------------------------------------
" translate key
"----------------------------------------------------------------------
let s:translate = { 
			\ "\<c-j>" : "\<down>",
			\ "\<c-k>" : "\<up>",
			\ "\<PageUp>" : "\<up>",
			\ "\<PageDown>" : "\<down>",
			\ "\<left>" : "\<left>",
			\ "\<right>" : "\<right>",
			\ "\<up>" : "\<up>",
			\ "\<down>" : "\<down>",
			\ "\<c-h>" : "\<left>",
			\ "\<c-l>" : "\<right>",
			\ "\<bs>" : "\<left>",
			\ }


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
function! s:config(what) abort
	return navigator#config#get(s:opts, a:what)
endfunc


"----------------------------------------------------------------------
" init keymap and open window
"----------------------------------------------------------------------
function! navigator#state#init(opts) abort
	let s:opts = deepcopy(a:opts)
	let s:popup = get(g:, 'quickui_navigator_popup', 0)
	let s:vertical = s:config('vertical')
	let s:position = navigator#config#position(s:config('position'))
	let s:screencx = &columns
	let s:screency = &lines
	let s:prefix = get(a:opts, 'prefix', '')
	if s:vertical == 0
		let s:wincx = s:screencx
		let s:wincy = s:config('min_height')
	else
		let s:wincx = s:config('min_width')
		let s:wincy = winheight(0)
	endif
	let s:state = 0
	let s:exit = 0
	let s:path = []
	call navigator#display#init(s:opts)
	return 0
endfunc


"----------------------------------------------------------------------
" close window
"----------------------------------------------------------------------
function! navigator#state#close() abort
	if s:state >= 0
		call navigator#display#close()
	endif
	let s:state = -1
endfunc


"----------------------------------------------------------------------
" translate path elements from key to label
"----------------------------------------------------------------------
function! s:translate_path(path)
	let path = []
	if s:prefix != ''
		let t = navigator#charname#get_key_label(s:prefix)
		let path += [t]
	endif
	for p in a:path
		let t = navigator#charname#get_key_label(p)
		let path += [t]
	endfor
	return path
endfunc


"----------------------------------------------------------------------
" resize window to fit 
"----------------------------------------------------------------------
function! navigator#state#resize(ctx) abort
	let ctx = a:ctx
	let padding = navigator#config#get(s:opts, 'padding')
	if s:vertical == 0
		let height = ctx.cy
		call navigator#display#resize(-1, height)
	else
		let width = ctx.cx
		call navigator#display#resize(width, -1)
	endif
endfunc


"----------------------------------------------------------------------
" select: return key array
"----------------------------------------------------------------------
function! navigator#state#select(keymap, path) abort
	let keymap = navigator#config#visit(a:keymap, [])
	let ctx = navigator#config#compile(keymap, s:opts)
	if len(ctx.items) == 0
		return []
	endif
	call navigator#layout#init(ctx, s:opts, s:wincx, s:wincy)
	if ctx.pg_count <= 0
		return []
	endif
	let pg_count = ctx.pg_count
	let pg_size = ctx.pg_size
	let pg_index = 0
	call navigator#layout#fill_pages(ctx, s:opts)
	if s:vertical == 0
		call navigator#display#resize(-1, ctx.pg_height)
	endif
	let map = {}
	for key in ctx.keys
		let item = ctx.items[key]
		let code = item.code
		let map[code] = key
	endfor
	let path = s:translate_path(a:path)
	let context = navigator#config#fetch('context', {})
	while 1
		let context.page = ctx.pages[pg_index]
		let context.index = pg_index
		call navigator#config#store('context', context)
		call navigator#state#resize(ctx)
		call navigator#display#update(ctx.pages[pg_index].content, path)
		noautocmd redraw
		try
			let code = getchar()
		catch /^Vim:Interrupt$/
			let code = "\<C-C>"
		endtry
		let ch = (type(code) == v:t_number)? nr2char(code) : code
		if ch == "\<ESC>" || ch == "\<c-c>"
			let s:exit = 1
			return []
		elseif has_key(s:translate, ch)
			let newch = s:translate[ch]
			if newch == "\<down>"
				let pg_index += 1
				let pg_index = (pg_index >= pg_count)? 0 : pg_index
			elseif newch == "\<up>"
				let pg_index -= 1
				let pg_index = (pg_index < 0)? (pg_count - 1) : pg_index
			elseif newch == "\<left>"
				return []
			endif
		elseif has_key(map, ch)
			let key = map[ch]
			let item = ctx.items[key]
			if item.child == 0
				return [key]
			endif
			let km = navigator#config#visit(keymap, [key])
			let hr = navigator#state#select(km, path + [key])
			if hr != []
				return [key] + hr
			endif
			if s:exit != 0
				return []
			endif
		endif
	endwhile
endfunc


"----------------------------------------------------------------------
" open keymap
"----------------------------------------------------------------------
function! navigator#state#open(keymap, opts) abort
	let opts = deepcopy(a:opts)
	let hr = navigator#state#init(opts)
	if hr != 0
		return []
	endif
	redraw
	let key_array = navigator#state#select(a:keymap, [])
	call navigator#state#close()
	return key_array
endfunc


