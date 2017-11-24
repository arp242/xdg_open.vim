" netrw compatibility; for example for fugitive.vim

fun! netrw#BrowseX(url, arg)
	return xdg_open#open(a:url)
endfun

fun! netrw#NetrwBrowseX(url, arg)
	return xdg_open#open(a:url)
endfun
