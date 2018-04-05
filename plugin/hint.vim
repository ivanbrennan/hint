if exists('g:loaded_hint') | finish | endif
let g:loaded_hint = 1

augroup HintHighlight
  autocmd!
  autocmd CmdlineEnter     [/\?] call hint#prepare_highlights()
  autocmd CmdlineEnter   [:>=@-] call hint#clear_highlight()
  autocmd InsertEnter,WinLeave * call hint#clear_highlight()
  autocmd WinEnter             * call hint#cleanup()
augroup END

let s:display = get(g:, 'hint_center_results', 0) ? 'zvzz' : 'zv'

func! s:map(keys, plug)
  if !empty(a:keys) && !hasmapto(a:plug)
    exec 'nmap <silent>' a:keys a:plug
  endif
  exec 'nnoremap <silent>' a:plug
        \ a:keys .
        \ s:display .
        \ ':call hint#add_highlights()<CR>'
endf

call s:map('#',  '<Plug>(hint-#)')
call s:map('*',  '<Plug>(hint-*)')
call s:map('N',  '<Plug>(hint-N)')
call s:map('g#', '<Plug>(hint-g#)')
call s:map('g*', '<Plug>(hint-g*)')
call s:map('n',  '<Plug>(hint-n)')
call s:map('',   '<Plug>(hint_highlight)')

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
