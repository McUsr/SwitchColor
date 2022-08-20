" SwitchColor plugin. h SwitchColor
" Copyright (c) 2022 Tommy Bollman/McUsr Vim Licence.
" version 0.0.6 Added patch by uCoolioDood@Reddit for streamlining
" assignmet of shortcut keys.
" ver: 0.0.7 Rewritten to utilize lazy loading, bugfixes hopefully
" MS-Win compatible.
if v:version < 700 || exists('g:loaded_switchcolor_fully') || &cp
 	finish
endif

if !exists("s:loaded_switchcolor_initially")
" ================================================================
" Keybindings. Smartest to leave alone, and remap in vimrc.
" ================================================================
	let s:fallback_scheme = get(g:, 'SC_colosch_fback', "desert")

	nnoremap <Plug>SwitchColorForward :<c-u>call SwiColSwitchColor(1)<CR>
	nnoremap <Plug>SwitchColorBackward :<c-u>call SwiColSwitchColor(-1)<CR>
	nnoremap <Plug>SwitchColorCycle :<c-u>colorscheme <C-D>
	nnoremap <Plug>SwitchColorEcho :<c-u>colorscheme <CR>

	if ! exists('g:switchcolor_use_own_mappings')
		execute "set <M-c>=\ec"
		nmap <unique> <silent> <M-c> <Plug>SwitchColorCycle
		execute "set <M-g>=\eg"
		nmap <unique> <silent> <M-g> <Plug>SwitchColorEcho
		execute "set <M-6>=\e6"
		nmap <unique> <silent> <M-6> <Plug>SwitchColorForward
		execute "set <M-5>=\e5"
		nmap <unique> <silent> <M-5> <Plug>SwitchColorBackward
	endif
	" ================================================================
	" Functions for reading/writing current colorscheme to/from disk.
	" ================================================================
	function! SwiColAssertCURCOLOR()
	" Asserts we have a value, before writing, and reading
		let l:probe      =""
		try
			let l:probe    = g:CURCOLOR
		catch /^Vim\%((\a\+)\)\=:E/	 " catch all Vim errors
		endtry 
		if l:probe == ""
			let g:CURCOLOR = s:fallback_scheme 
		endif
	endfunction 

	function! SwiColGetColorFileName()
		if !exists('g:SC_dotfile_name')
				let fileInter             = ''
			" shamelessly stolen from Y. Lakshmanan's MRU plugin.
				if has('unix') || has('macunix')
						let fileInter         = $HOME . '/.curcolors'
				else
						let fileInter         = $VIM . '/_curcolors'
						if has('win32')
								" MS-Windows
								if $USERPROFILE != ''
										let fileInter = $USERPROFILE . '\_curcolors'
								endif
						endif
				endif
				let s:fileCurColor        = expand(fileInter) 
		else
				let s:fileCurColor        = expand(g:SC_dotfile_name)
		endif
	endfunction

	function! SwiColSourceCURCOLOR()
	" on VimEnter/WinEnter
		call SwiColGetColorFileName()
		let l:colorFile  = s:fileCurColor
		try
			let l:firstL   = readfile(l:colorFile ,'',1 )
			let l:firstLs	 =	string(l:firstL[0])
			let g:CURCOLOR = substitute(l:firstLs, "'", '', 'g')
		catch /^Vim\%((\a\+)\)\=:E/	 " catch all Vim errors
		endtry
		call SwiColAssertCURCOLOR()
		execute "colorscheme " .. g:CURCOLOR
	endfunction

	function! SwiColFlushCURCOLOR()
	" to be installed on VimLeave
		let g:CURCOLOR   = SwiColCurrentScheme()
		call SwiColAssertCURCOLOR()
		let	l:colorFile  = s:fileCurColor
		call writefile([g:CURCOLOR], l:colorFile, "S")
	endfunction

	function! SwiColCurrentScheme()
		let l:scrapval   = ""
		redir => l:scrapval
			silent execute "colorscheme"
		redir END
		return substitute(l:scrapval, '^\n*', '', '')
	endfunction

	function! SwiColRefreshColor()
		let g:CURCOLOR = SwiColCurrentScheme()
		let cmdStr = "colorscheme " .. g:CURCOLOR
		silent execute cmdStr 
	endfunction
	" ================================================================
	" Event handling: reading, setting, writing, refreshing Netrw. 
	" ================================================================
  let initColScheme = 0
	augroup setupColorScheme
		autocmd!
		autocmd! VimEnter * if initColScheme == 0
					\	| call SwiColSourceCURCOLOR()
					\ | let initColScheme = 1
					\ | endif 
		autocmd! WinEnter * if initColScheme == 0
					\ | call SwiColSourceCURCOLOR()
					\ | let initColScheme = 1
					\| endif  
		autocmd! VimLeave * call SwiColFlushCURCOLOR()
		autocmd! FileType netrw set nocursorline | call SwiColRefreshColor()
	augroup END
	let s:loaded_switchcolor_initially = 1 
	" Source rest of plugin upon demand.
	exe 'au FuncUndefined SwiCol* source ' .. expand('<sfile>') 
	finish
endif
" ================================================================
" The part that loads on demand via "source" is below.
" ================================================================
let g:loaded_switchcolor_fully = 1 "No point in resourcing/loading.

let s:validschemes = [ 'whole_runtime', 'local_only', 'user_specified' ]

function! SwiColGetUserValues()
	" internal fall back is "whole_runtime"
	let s:schemesforuse          = get(g:, 'SC_schemesforuse', 'whole_runtime')
	if  (index( s:validschemes,s:schemesforuse) == -1 )
		echoerr "SwitchColor: wrong value in g:SC_schemesforuse,uses 'whole_runtime'"
		let s:schemesforuse        = 'whole_runtime' " FALLBACK
	endif

	if s:schemesforuse == 'user_specified' 
		let s:favcolschemes   		 = get(g:, 'SC_colorscheme_place', "")
		if s:favcolschemes == ""
			echoerr "SwitchColor: no value in g:SC_colorscheme_place,uses
						\ g:SC_schemesforuse = 'whole_runtime' as FALLBACK"
			let s:schemesforuse        = 'whole_runtime' " FALLBACK
		endif 
		" we need to check if this works, and if not, we fall back to runtime.
	endif
	let s:rejects 							   = get(g:, 'SC_excluded', [] )
endfunction

function! SwiColParseUserValues()
	call SwiColGetUserValues()
	if has('unix') || has('macunix')
		if s:schemesforuse  == 'whole_runtime' 
			let paths = split(globpath(&runtimepath, 'colors/*.vim'), "\n")
		elseif s:schemesforuse  == 'local_only' 
			let paths = split(globpath('~/.vim/', 'colors/*.vim'), "\n")
		else " user_specified
			let paths = split(globpath(s:favcolschemes, '/*.vim'), "\n")
		endif
	else " MS something.
			if s:schemesforuse  == 'whole_runtime' 
			let paths = split(globpath(&runtimepath, 'colors\*.vim'), "\n")
		elseif s:schemesforuse  == 'local_only' 
		 let winvimPath=expand($VIM)
			let paths = split(globpath(winvimPath, 'colors\*.vim'), "\n")
		else " user_specified
			let paths = split(globpath(s:favcolschemes, '\*.vim'), "\n")
		endif
	endif 

	let s:swcolors = map(paths, 'fnamemodify(v:val, ":t:r")')

	call sort(s:swcolors)
	call uniq(s:swcolors)
	let s:swback = 0    " background variants light/dark was not yet switched
	let s:ixCurScheme = index(s:swcolors,g:CURCOLOR)

	if s:ixCurScheme == -1 
	" Scenario is that we have changed collection of colors themes, eg. from
	" dark to light, or to c-syntax from html.
		let s:ixCurScheme = 1
		let g:CURCOLOR = s:swcolors[s:ixCurScheme]
	endif 
endfunction

call SwiColParseUserValues()

function! SwiColDebugInfo()
	call SwiColParseUserValues() "Since may have changed values in vimrc 
	execute "echo \"s:schemesforuse:\"     " .. "s:schemesforuse"
	execute "echo \"s:fileCurColor:\"       " .. "s:fileCurColor"    
	execute "echo \"s:fallback_scheme:\" " .. "s:fallback_scheme" 
	execute "echo \"s:rejects:\" " .. "s:rejects"
  if s:schemesforuse == 'user_specified' 
		execute "echo \"s:favcolschemes:\"     " .. "s:favcolschemes"   
	endif
	execute "echo \"g:CURCOLOR:\"             " .. "g:CURCOLOR"
	let s:ixCurScheme = index(s:swcolors,g:CURCOLOR)
	execute "echo \"s:ixCurScheme\" " .. "s:ixCurScheme"
	execute "echo \"s:swcolors\" " .. "s:swcolors"
endfunction
" ================================================================
" Actual switching between schemes
" ================================================================
" initial values:
let s:ixCurScheme = 0
let s:swback = 0
function! SwiColSwitchColor(swinc)
	let l:wasLight = 0
	let g:CURCOLOR = SwiColCurrentScheme()
	" We start from the right place.
	" TRICK! so, we sort our schemes uniquely, to avoid problems.
	let s:ixCurScheme = index(s:swcolors,g:CURCOLOR)
	" if have switched background: dark/light
	let l:oldix = s:ixCurScheme
	while 1
		if (l:oldix == s:ixCurScheme) && (&background == "dark") 
			execute "set background=light"
			if exists('g:colors_name')
				" vim global set when successful change.
				break
			else
				let s:ixCurScheme = s:ixCurScheme + a:swinc
				let l:oldidx = -2 
			endif
		elseif (l:oldix == s:ixCurScheme) && ( &background == "light") 
			let l:wasLight = 1
			execute "set background=dark"
			let s:ixCurScheme = s:ixCurScheme + a:swinc
			let l:oldix = -2
		else
			" we are about to change the colorscheme
			" the scheme is black. 
			let s:ixCurScheme = s:ixCurScheme % len(s:swcolors)
			if (s:ixCurScheme < 0 ) && (a:swinc < 0 )
				let s:ixCurScheme = len(s:swcolors) - 1
			endif 
			call sort(s:rejects)
			" if not in rejects list
			if (index(s:rejects, s:swcolors[s:ixCurScheme]) == -1)
				execute "colorscheme " .. s:swcolors[s:ixCurScheme]
				if (l:wasLight == 1)  && (a:swinc < 0)
					execute "set background=light"
					if (!exists('g:colors_name'))
						execute "set background=dark"
						execute "colorscheme " .. s:swcolors[s:ixCurScheme]
						let l:wasLight = 0
					endif
				endif
				let g:CURCOLOR = s:swcolors[s:ixCurScheme]
				break
			else
				let s:ixCurScheme = s:ixCurScheme + a:swinc 
			endif
		endif
	endwhile
	" show current name on screen. :h :echo-redraw
	redraw
	execute "colorscheme"
endfunction
