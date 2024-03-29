Re-implements netrw's `gx` command with a call to `xdg-open` (or a similar tool
of your choosing). You can also use `gX` to always open a path as an URL (so
that e.g. `example.com/path` opens `http://example.com/path`, rather than a
local path).

This is especially useful if you're using dirvish or some other file-manager
other than netrw.

Is this fully compatible with netrw?
------------------------------------
It should be for most purposes, but feature-for-feature (or bug-for-bug)
compatibility was not a goal. Notable changes are:

- Just try to run `xdg-open` (or another command of your choosing); no
  complicated fallbacks if it fails.

- The default is to get the `<cWORD>` instead of `<cfile>`. This works better
  for URLs with query parameters. Also allow using an expression to get the
  text.

- The command is run in the background as a job, which is much more convenient
  and allows displaying an error only if the command fails.

Can I disable netrw completely?
-------------------------------

- To only disable gx-related functionality:

		let g:netrw_nogx = 1

- To disable all of netrw:

		let g:loaded_netrw = 1

- To disable the netrw doc files you need to remove the doc file at 
  `$VIMRUNTIME/doc/pi_netrw.txt` and rebuild the help tags with:

		:helptags $VIMRUNTIME/doc

  This has the advantage of not cluttering `:helpgrep` or tab completion.

  You will need write permissions here (e.g. run it as root). Unfortunately you
  will need to re-run this after every upgrade.

See `:help xdg_open` for the full documentation.
