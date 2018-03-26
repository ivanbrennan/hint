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

func! s:set_hlsearch(...)
  call s:delete_hlmatch()
  let &hlsearch = get(a:, 1, 1)
endf

func! s:delete_hlmatch()
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

  let highlight = get(g:, 'HintHighlightGroup', 'IncSearch')
  let pattern='\c\%#' . @/  " \c case insensitive
                            " \%# current cursor position
                            " @/ current search pattern
  let w:hint_hlmatch = matchadd(highlight, pattern)
endf

func! s:next_cursormove_clears_highlight()
  augroup HintCursorMoved
    autocmd!
    autocmd CursorMoved * call hint#clear_highlight()
  augroup END
endf

func! s:next_cursormove_adds_hlmatch()
  augroup HintCursorMoved
    autocmd!
    autocmd CursorMoved * call s:add_hlmatch()
  augroup END
endf

func! s:remove_cursormove_autocmd()
  augroup HintCursorMoved
    autocmd!
  augroup END
endf
