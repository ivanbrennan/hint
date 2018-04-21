func! hint#prepare_highlights() abort
  call s:set_hlsearch()
  call s:next_cursormove_adds_hlmatch()
endf

func! hint#add_highlights() abort
  call s:set_hlsearch()
  call s:add_hlmatch()
endf

func! hint#clear_highlight() abort
  call s:remove_cursormove_autocmd()
  call s:set_hlsearch(0)
endf

func! hint#is_highlighted() abort
  return exists('w:hint_hlmatch') || get(v:, 'hlsearch', 0)
endf

" Called from WinEnter autocmd to clean up stray `matchadd()` vestiges.
" If we switch into a window and there is no 'hlsearch' in effect but we do have
" a `w:hint_hlmatch` variable, it means that `:nohiglight` was probably run
" from another window and we should clean up the straggling match and the
" window-local variable.
func! hint#cleanup() abort
  if !exists('v:hlsearch') || !v:hlsearch
    call hint#clear_highlight()
  endif
endf

func! s:set_hlsearch(...) abort
  call s:delete_hlmatch()
  let &hlsearch = get(a:, 1, 1)
endf

func! s:delete_hlmatch() abort
  if exists('w:hint_hlmatch')
    try
      call matchdelete(w:hint_hlmatch)
    catch /\v<(E802|E803)>/
      " https://github.com/wincent/Loupe/issues/1
    finally
      unlet w:hint_hlmatch
    endtry
  endif
endf

func! s:add_hlmatch() abort
  call s:next_cursormove_clears_highlight()
  let group = get(g:, 'HintHighlightGroup', 'IncSearch')
  let w:hint_hlmatch = matchadd(group, s:pattern())
endf

func! s:pattern()
  " Prefix may contain, but not end with backslash
  let match = substitute(@/, '\C\v^(.*[^\\])*(\\\\)*\\zs', '', '')
  " \%# current cursor position
  return '\c\%#' . match
endf

func! s:next_cursormove_clears_highlight() abort
  augroup HintCursorMoved
    autocmd!
    autocmd CursorMoved * call hint#clear_highlight()
  augroup END
endf

func! s:next_cursormove_adds_hlmatch() abort
  augroup HintCursorMoved
    autocmd!
    autocmd CursorMoved * call s:add_hlmatch()
  augroup END
endf

func! s:remove_cursormove_autocmd() abort
  augroup HintCursorMoved
    autocmd!
  augroup END
endf
