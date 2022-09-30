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
	if text is -1
		return
	endif

	" Markdown URLs like:
	"   [label](example.com)
	"   [label][ref]
	"   [label]
	if &ft == 'markdown'
		let e = ''
		if text =~ '^\[.\{}\](.\{})'
			let e = matchlist(text, '](\(.\{}\))')[1]
		elseif text =~ '^\[.\{}\]\[.\{}\]' || text =~ '^\[.\{}\]'
			let ref = matchlist(text, '\(\[\([^\[]\{}\)\]\)\+')[2]
			if ref != ''
				let ref = '[' .. ref .. ']:'
				let def = getline(1, '$')->filter({_, l -> l[: len(ref) - 1] ==# ref })
				if len(def) > 0
					let def = def[0]->split(':')[1:]->join(':')->trim()
					if def != ''
						let e = def
					endif
				endif
			endif
		endif
		if e != ''
			let text = e
		endif
	endif

	if a:as_url && text !~ '^\w\{3,32}:\/\/'
		let text = 'http://' .. text
	endif

	echo text
	return s:run(text)
endfun

let s:jobs = #{}
fun! s:exit_cb(job, status) abort
	let pid = job_info(a:job).process
	if a:status isnot 0
		echohl Error
		echom printf('xdg-open: exit %d running %s', a:status, s:jobs[pid])
		echohl None
	endif
	silent! call remove(s:jobs, pid)
endfun

" Run the command
fun! s:run(path) abort
	if exists('*job_start')
		let cmd = [g:xdg_open_command, a:path]
		let j = job_start(cmd->flatten(), #{
			\ out_cb:  {ch, msg -> 0},
			\ err_cb:  {ch, msg -> 0},
			\ exit_cb: function('s:exit_cb'),
		\ })
		let s:jobs[job_info(j).process] = cmd
	" TODO: can also add neovim support I guess.
	else
		call system(printf('%s %s &', g:xdg_open_command, shellescape(a:path)))
	endif
endfun

" Get text to open
fun s:get_text(source) abort
	" Word under cursor
	if a:source is 0
		if g:xdg_open_match[0] is '<'
			let text = expand(g:xdg_open_match)
		else
			try
				let text = eval(g:xdg_open_match)
			catch
				echohl Error
				echom 'xdg-open: running g:xdg_open_match: ' .. v:exception
				echohl None
				return -1
			endtry
		endif
	" Visual selection
	elseif a:source is 1
		let save = @@
		try
			normal! gvy
			let text = substitute(@@, '\v(^\s*|\s*$)', '', 'g')
		finally
			let @@ = save
		endtry
		return text
	" Return as-is
	else
		let text = a:source
	endif

	" Remove wrapping quotes etc.
	for w in ['""', "''", '()', '[]', '{}', '**', '__']
		if text[0] == w[0] && text[len(text)-1] == w[1]
			let text = text[1:len(text)-2]
		endif
	endfor
	return text
endfun

let &cpo = s:save_cpo
unlet s:save_cpo
