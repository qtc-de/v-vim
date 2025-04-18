if exists("b:did_ftplugin")
	finish
endif

setlocal commentstring=//\ %s
setlocal makeprg=v\ %

if exists('b:undo_ftplugin')
	let b:undo_ftplugin .= "|setlocal commentstring< makeprg<"
else
	let b:undo_ftplugin = "setlocal commentstring< makeprg<"
endif

function! _VFormatFile()
	if exists('g:v_autofmt_bufwritepre') && g:v_autofmt_bufwritepre || exists('b:v_autofmt_bufwritepre') && b:v_autofmt_bufwritepre
		let substitution = system("v fmt -", join(getline(1, line('$')), "\n"))
		if v:shell_error != 0
			echoerr "While formatting the buffer via vfmt, the following error occurred:"
			echoerr printf("ERROR(%d): %s", v:shell_error, substitution)
		else
			let [_, lnum, colnum, _] = getpos('.')
			%delete
			call setline(1, split(substitution, "\n"))
			call cursor(lnum, colnum)
		endif
	endif
endfunction

function! _VAllmanFormat()
    " This function is ment to be used on single structs to align them
    " using v fmt without loosing Allman format
    let l:v_vim_reg_backup = [getreg('0'), getregtype('0')]")
    normal! gvy

    let l:selection = getreg('0')
    let l:substitution = trim(system("v fmt -", l:selection))

    if v:shell_error != 0
        echoerr "While formatting the buffer via vfmt, the following error occurred:"
        echoerr printf("ERROR(%d): %s", v:shell_error, l:substitution)
    else
        call setreg('0', l:substitution, l:v_vim_reg_backup[1])
        normal! gvp

        let l:line = getline('.')
        let l:repl = substitute(l:line, '\s*{$', "\n{", '')

        normal! dd
        call setreg('0', l:repl, 'V')
        normal! "0P
    endif

    call setreg('0', l:v_vim_reg_backup[0], l:v_vim_reg_backup[1])
endfunction

if has('autocmd')
	augroup v_fmt
		autocmd BufWritePre *.v call _VFormatFile()
	augroup END
endif

vnoremap F :<c-u>call _VAllmanFormat()<CR>
