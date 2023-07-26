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
command! -nargs=1 -range=0 Navigator 
			\ call navigator#start(0, 0, <q-args>, <line1>, <line2>, <count>)

command! -nargs=1 -range=0 NavigatorVisual
			\ call navigator#start(1, 0, <q-args>, <line1>, <line2>, <count>)

