if exists('g:loaded_hint') | finish | endif
let g:loaded_hint = 1

augroup HintHighlight
  autocmd!
  autocmd CmdlineEnter     [/\?] call hint#prepare_highlights()
  autocmd CmdlineEnter   [:>=@-] call hint#clear_highlight()
  autocmd InsertEnter,WinLeave * call hint#clear_highlight()
  autocmd WinEnter             * call hint#cleanup()
augroup END

func! s:map(keys)
  let s:center = get(g:, 'hint_center_results', 0)
  let s:center_string = s:center ? 'zz' : ''

  if !hasmapto('<Plug>(hint-' . a:keys . ')')
    execute 'nmap <silent> ' . a:keys . ' <Plug>(hint-' . a:keys . ')'
  endif
  execute 'nnoremap <silent> <Plug>(hint-' . a:keys . ') ' .
        \ a:keys .
        \ 'zv' .
        \ s:center_string .
        \ ':call hint#add_highlights()<CR>'
endf

call s:map('#')  " <Plug>(hint-#)
call s:map('*')  " <Plug>(hint-*)
call s:map('N')  " <Plug>(hint-N)
call s:map('g#') " <Plug>(hint-g#)
call s:map('g*') " <Plug>(hint-g*)
call s:map('n')  " <Plug>(hint-n)

if !hasmapto('<Plug>(hint_toggle_highlight)') && maparg('<M-u>', 'n') ==# ''
  nmap <silent> <unique> <M-u> <Plug>(hint_toggle_highlight)
endif

if !hasmapto('<Plug>(hint_cword)') && maparg('<M-U>', 'n') ==# ''
  nmap <silent> <unique> <M-U> <Plug>(hint_cword)
endif

nnoremap <silent> <unique> <expr> <Plug>(hint_toggle_highlight)
      \ hint#is_highlighted() ? ":call hint#clear_highlight()\<CR>"
      \                       : ":call hint#add_highlights()\<CR>"

nnoremap <silent> <unique> <Plug>(hint_cword)
      \ Mmz<C-O>*N`zzz<C-O>:call hint#add_highlights()<CR>
