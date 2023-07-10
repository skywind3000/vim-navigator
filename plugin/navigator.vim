"======================================================================
"
" navigator.vim - 
"
" Created by skywind on 2023/06/27
" Last Modified: 2023/06/27 22:54:41
"
"======================================================================


"----------------------------------------------------------------------
" Navigator
"----------------------------------------------------------------------
command! -nargs=* Navigator call s:Navigator(<q-args>) 
function! s:Navigator(prefix)
	if !exists('g:navigator')
		echohl ErrorMsg
		echo 'g:navigator is not defined'
		echohl None
		return 0
	endif
	let t = get(g:, 'navigator', {})
	call navigator#cmd(t, a:prefix)
	" echom "> prefix: " . a:prefix
	return 0
endfunc


