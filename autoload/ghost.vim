scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


" base source
" open-browser.vim
" https://github.com/tyru/open-browser.vim
function! s:get_url_from_pos(lnum, col)
    let line = getline(a:lnum)
    let col = a:col

    if line[col-1] !~# '\S'    " cursor is not on URL
        return ''
    endif
    " Get continuous non-space string under cursor.
    let left = col <=# 1 ? '' : line[: col-2]
    let right = line[col-1 :]
    let nonspstr = matchstr(left, '\S\+$').matchstr(right, '^\S\+')
    " Extract URL.
    " via https://github.com/mattn/vim-textobj-url/blob/af1edbe57d4f05c11e571d4cacd30672cdd9d944/autoload/textobj/url.vim#L2
    let re_url = '\(https\?\|ftp\)://[a-zA-Z0-9][a-zA-Z0-9_-]*\(\.[a-zA-Z0-9][a-zA-Z0-9_-]*\)*\(:\d\+\)\?\(/[a-zA-Z0-9_/.+%#?&=;@$,!''*~-]*\)\?'
    let url = matchstr(nonspstr, re_url)
    return url
endfunction


function! s:get_title_from_url(url, ...)
	let output_encode = get(a:, 1, &enc)

	let body = webapi#http#get(a:url).content
	let enc = matchstr(body, 'charset=\zs[^"'']*\ze["'']')
	if empty(enc)
		let enc = matchstr(body, 'charset=["'']\zs[^"'']*\ze["'']')
	endif

	return iconv(matchstr(body, '<title>\zs.*\ze<\/title>'), empty(enc) ? 'uft-8' : enc, output_encode)
endfunction


let s:tilte_cache = {}
function! s:get_title_from_url_memo(url, ...)
	let output_encode = get(a:, 1, &enc)

	if empty(a:url)
		return ""
	endif
	if !has_key(s:tilte_cache, a:url)
		let s:tilte_cache[a:url] = s:get_title_from_url(a:url, output_encode)
	endif
	return s:tilte_cache[a:url]
endfunction


function! ghost#get_title(...)
	return call("s:get_title_from_url_memo", a:000)
endfunction

function! ghost#get_url_on_cursor()
	return s:get_url_from_pos(line("."), col("."))
endfunction

function! ghost#balloonexpr_url_title()
	return s:get_title_from_url(s:get_url_from_pos(v:beval_lnum, v:beval_col), &termencoding)
" 	return ghost#get_title(s:get_url_from_pos(v:beval_lnum, v:beval_col), &termencoding)
endfunction

function! ghost#clear_cache()
	let s:tilte_cache = {}
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
