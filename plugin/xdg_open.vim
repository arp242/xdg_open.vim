" xdg_open.vim: Run xdg-open from Vim; replaces netrw's gx.
"
" http://arp242.net/code/xdg_open.vim
"
" See the bottom of this file for copyright & license information.
"


"##########################################################
" Initialize some stuff
scriptencoding utf-8
if exists('g:loaded_xdg_open') | finish | endif
let g:loaded_xdg_open = 1
let s:save_cpo = &cpo
set cpo&vim


"##########################################################
" The default settings
if !exists('g:xdg_open_command')
	let g:xdg_open_command = exists('g:netrw_browsex_viewer') ? g:netrw_browsex_viewer : 'xdg-open'
endif
if !exists('g:xdg_open_match')
	let g:xdg_open_match = exists('g:netrw_gx') ? g:netrw_gx : '<cWORD>'
endif


"##########################################################
" Mappings
nnoremap <silent> <Plug>(xdg-open-n) :call xdg_open#open(0)<CR>
xnoremap <silent> <Plug>(xdg-open-x) :call xdg_open#open(1)<CR>

if !exists('g:xdg_open_no_map') || empty(g:xdg_open_no_map)
	nmap gx <Plug>(xdg-open-n)
	xmap gx <Plug>(xdg-open-x)
endif


"##########################################################
" Functions

" Open word under cursor or selection
fun! xdg_open#open(source) abort
	return s:open(a:source, 0)
endfun

" Like open(), but give an error if the word doesn't look like an url
fun! xdg_open#open_url(source) abort
	return s:open(a:source, 1)
endfun

fun s:open(source, strict)
	let l:maybe_url = s:get_text(a:source)
	if l:maybe_url !~ '^\w\{3,32}:\/\/'
		if a:strict
			echoerr 'Not an url: ' . l:maybe_url
			return
		else
			let l:maybe_url = 'http://' . l:maybe_url
		endif
	endif

	return s:run(l:maybe_url)
endfun


" Run the command
fun! s:run(path) abort
	" TODO: Make & an option?
	call system(printf('%s %s &', g:xdg_open_command, shellescape(a:path)))
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


" The MIT License (MIT)
"
" Copyright © 2016 Martin Tournoij
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" The software is provided "as is", without warranty of any kind, express or
" implied, including but not limited to the warranties of merchantability,
" fitness for a particular purpose and noninfringement. In no event shall the
" authors or copyright holders be liable for any claim, damages or other
" liability, whether in an action of contract, tort or otherwise, arising
" from, out of or in connection with the software or the use or other dealings
" in the software.
