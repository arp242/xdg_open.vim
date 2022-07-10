scriptencoding utf-8
if exists('g:loaded_xdg_open') | finish | endif
let g:loaded_xdg_open = 1
let s:save_cpo = &cpo
set cpo&vim


if !exists('g:xdg_open_command')
	let g:xdg_open_command = exists('g:netrw_browsex_viewer') ? g:netrw_browsex_viewer : 'xdg-open'
endif
if !exists('g:xdg_open_match')
	let g:xdg_open_match = exists('g:netrw_gx') ? g:netrw_gx : '<cWORD>'
endif


nnoremap <silent> <Plug>(xdg-open-n)     :call xdg_open#open(0)<CR>
xnoremap <silent> <Plug>(xdg-open-x)     :call xdg_open#open(1)<CR>
nnoremap <silent> <Plug>(xdg-open-url-n) :call xdg_open#open_url(0)<CR>
xnoremap <silent> <Plug>(xdg-open-url-x) :call xdg_open#open_url(1)<CR>

if !exists('g:xdg_open_no_map') || empty(g:xdg_open_no_map)
	nmap gx <Plug>(xdg-open-n)
	xmap gx <Plug>(xdg-open-x)
	nmap gX <Plug>(xdg-open-url-n)
	xmap gX <Plug>(xdg-open-url-x)
endif


" Open word under cursor or selection
fun! xdg_open#open(source) abort
	return s:open(a:source, 0)
endfun

" Like open(), but prefix any path with "http://" if it doesn't have it already,
" ensuring it always opens an URL.
fun! xdg_open#open_url(source) abort
	return s:open(a:source, 1)
endfun

fun s:open(source, as_url)
	let text = s:get_text(a:source)
	if a:as_url && text !~ '^\w\{3,32}:\/\/'
		let text = 'http://' .. text
	endif
	return s:run(text)
endfun

" Run the command
fun! s:run(path) abort
	" TODO: Make & an option?
	let cmd = printf('%s %s &', g:xdg_open_command, shellescape(a:path))
	if get(g:, 'xdg_open_silent', 1)
		echom cmd
	endif
	call system(cmd)
endfun

" Get text to open
fun s:get_text(source) abort
	" Word under cursor
	if a:source is 0
		let l:text = expand(g:xdg_open_match)
	" Visual selection
	elseif a:source is 1
		let l:save = @@
		normal! gvy
		let l:text = substitute(@@, '\v(^\s*|\s*$)', '', 'g')
		let @@ = l:save
		return l:text
	" Return as-is
	else
		let l:text = a:source
	endif

	" Remove wrapping quotes etc.
	for l:w in ['""', "''", '()', '[]', '{}', '**', '__']
		if l:text[0] == l:w[0] && l:text[len(l:text)-1] == l:w[1]
			let l:text = l:text[1:len(l:text)-2]
		endif
	endfor

	return l:text
endfun

let &cpo = s:save_cpo
unlet s:save_cpo
