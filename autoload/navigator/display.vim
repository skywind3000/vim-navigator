"======================================================================
"
" display.vim - 
"
" Created by skywind on 2023/06/26
" Last Modified: 2023/06/26 16:36:13
"
"======================================================================


"----------------------------------------------------------------------
" internal variable
"----------------------------------------------------------------------
let s:popup = 0
let s:opts = {}
let s:screencx = &columns
let s:screency = &lines
let s:wincx = 0
let s:wincy = 0
let s:vertical = 0
let s:position = ''

let s:bid = -1
let s:previous_wid = -1
let s:working_wid = -1


"----------------------------------------------------------------------
" internal functions
"----------------------------------------------------------------------
function! s:config(what) abort
	return navigator#config#get(s:opts, a:what)
endfunc


"----------------------------------------------------------------------
" window open
"----------------------------------------------------------------------
function! s:win_open() abort
	let opts = s:opts
	let vertical = navigator#config#get(opts, 'vertical')
	let position = navigator#config#get(opts, 'position')
	let min_height = navigator#config#get(opts, 'min_height')
	let min_width = navigator#config#get(opts, 'min_width')
	let s:previous_wid = winnr()
	call navigator#utils#save_view()
	if vertical == 0
		exec printf('%s %dsplit', position, min_height)
	else
		exec printf('%s %dvsplit', position, min_width)
	endif
	call navigator#utils#restore_view()
	let s:working_wid = winnr()
	if s:bid < 0
		let s:bid = navigator#utils#create_buffer()
	endif
	let bid = s:bid
	exec 'b ' . bid
	setlocal bt=nofile nobuflisted nomodifiable
	setlocal nowrap nonumber nolist nocursorline nocursorcolumn noswapfile
	if has('signs') && has('patch-7.4.2210')
		setlocal signcolumn=no 
	endif
	if has('spell')
		setlocal nospell
	endif
	if has('folding')
		setlocal fdc=0
	endif
	call navigator#utils#update_buffer(bid, [])
endfunc


"----------------------------------------------------------------------
" window close
"----------------------------------------------------------------------
function! s:win_close() abort
	if s:working_wid > 0
		call navigator#utils#save_view()
		exec printf('%dclose', s:working_wid)
		call navigator#utils#restore_view()
		let s:working_wid = -1
		if s:previous_wid > 0
			exec printf('%dwincmd w', s:previous_wid)
			let s:previous_wid = -1
		endif
	endif
endfunc


"----------------------------------------------------------------------
" window resize
"----------------------------------------------------------------------
function! s:win_resize(width, height) abort
	if s:working_wid > 0
		call navigator#utils#window_resize(s:working_wid, a:width, a:height)
	endif
endfunc


"----------------------------------------------------------------------
" window update
"----------------------------------------------------------------------
function! s:win_update(textline, status) abort
	if s:bid > 0
		call navigator#utils#update_buffer(s:bid, a:textline)
		if s:working_wid > 0 && s:working_wid == winnr()
			let m = ' => '
			let t = join(a:status, m) . m
			let &l:statusline = 'SELECT: ' . t
			setlocal ft=navigator
		endif
	endif
endfunc


"----------------------------------------------------------------------
" window execute
"----------------------------------------------------------------------
function! s:win_execute(command) abort
	if type(a:command) == type([])
		let command = join(a:command, "\n")
	elseif type(a:command) == type('')
		let command = a:command
	else
		let command = a:command
	endif
	if s:working_wid > 0
		let wid = winnr()
		noautocmd exec printf('%dwincmd w', s:working_wid)
		exec command
		noautocmd exec printf('%dwincmd w', wid)
	endif
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:popup_open() abort
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:popup_close() abort
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:popup_resize(width, height)
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:popup_update(content, status)
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:popup_execute(command)
endfunc


"----------------------------------------------------------------------
" initialize
"----------------------------------------------------------------------
function! navigator#display#init(opts) abort
	let s:config_popup = get(g:, 'quickui_navigator_popup', 0)
	let s:config_opts = a:opts
	let s:opts = a:opts
	let s:popup = get(g:, 'quickui_navigator_popup', 0)
	let s:vertical = s:config('vertical')
	let s:position = navigator#config#position(s:config('position'))
	let s:screencx = &columns
	let s:screency = &lines
	if s:vertical == 0
		let s:wincx = s:screencx
		let s:wincy = s:config('min_height')
	else
		let s:wincx = s:config('min_width')
		let s:wincy = winheight(0)
	endif
	if s:popup == 0
		call s:win_open()
	else
		call s:popup_open()
	endif
endfunc


"----------------------------------------------------------------------
" close 
"----------------------------------------------------------------------
function! navigator#display#close() abort
	if s:popup == 0
		call s:win_close()
	else
		call s:popup_close()
	endif
endfunc


"----------------------------------------------------------------------
" resize
"----------------------------------------------------------------------
function! navigator#display#resize(width, height) abort
	if s:popup == 0
		call s:win_resize(a:width, a:height)
	else
		call s:popup_resize(a:width, a:height)
	endif
endfunc


"----------------------------------------------------------------------
" update
"----------------------------------------------------------------------
function! navigator#display#update(content, status) abort
	if s:popup == 0
		call s:win_update(a:content, a:status)
	else
		call s:popup_update(a:content, a:status)
	endif
endfunc


"----------------------------------------------------------------------
" execute
"----------------------------------------------------------------------
function! navigator#display#execute(command) abort
	if s:popup == 0
		call s:win_execute(a:command)
	else
		call s:popup_execute(a:command)
	endif
endfunc


" vim: set ts=4 sw=4 tw=78 noet :

