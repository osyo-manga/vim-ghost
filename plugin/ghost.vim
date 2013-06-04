scriptencoding utf-8
if exists('g:loaded_ghost')
  finish
endif
let g:loaded_ghost = 1

let s:save_cpo = &cpo
set cpo&vim


let g:ghost_enable_echo_title_cursor_moved = get(g:, "ghost_enable_echo_title_cursor_moved", 0)


command! -bar GhostEchoTitleOnCursorURL echo ghost#get_title(ghost#get_url_on_cursor())

augroup ghost
	autocmd!
	autocmd CursorMoved *
\		if g:ghost_enable_echo_title_cursor_moved
\|			GhostEchoTitleOnCursorURL
\|		endif
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
