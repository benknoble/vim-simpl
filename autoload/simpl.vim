function simpl#repl(...) abort
  let l:interpreter = get(b:, 'interpreter', &shell)
  let l:command = 'term'
  if a:0
    for l:opt in a:000
      let l:command .= printf(' %s', opt)
    endfor
  endif
  let l:command .= printf(' %s', l:interpreter)
  execute s:mods() l:command
  return win_getid()
endfunction

function simpl#shell(...) abort
  const l:save_restore = has_key(b:, 'interpreter')
  if l:save_restore
    let l:old_buf = bufnr('%')
    let l:old_interpreter = b:interpreter
    unlet b:interpreter
  endif
  const id = call('simpl#repl', a:000)
  if l:save_restore
    call setbufvar(l:old_buf, 'interpreter', l:old_interpreter)
  endif
  return id
endfunction

function s:popup(id) abort
  if a:id is# 0
    return
  endif
  const buf = win_id2win(a:id)->winbufnr()
  call win_gotoid(a:id)
  hide
  return popup_create(buf, s:popup_options())
endfunction

function s:popup_options() abort
  " look in current buffer and previous (since we just created the terminal buffer)
  return get(b:, 'simpl_popup_options',
        \ getbufvar('#', 'simpl_popup_options',
        \ get(g:, 'simpl_popup_options',
        \ #{minheight: &lines-10, minwidth: &columns-10, border:[], padding: []})))
endfunction

function simpl#popup_repl(...) abort
  return s:popup(call('simpl#repl', ['++close'] + a:000))
endfunction

function simpl#popup_load(...) abort
  return s:popup(call('simpl#load', ['++close'] + a:000))
endfunction

function simpl#popup_shell(...) abort
  return s:popup(call('simpl#shell', ['++close'] + a:000))
endfunction

function s:simpl() abort
  return get(g:, 'simpl', {})
endfunction

function s:should_do_load() abort
  return has_key(s:simpl(), &filetype)
endfunction

function s:do_load(expr, ...) abort
  let l:terms = term_list()
  call filter(l:terms, 'bufwinid(v:val) isnot# -1 && term_getstatus(v:val) =~# "running"')
  if empty(l:terms)
    call call(function("simpl#repl"), a:000)
    let l:terms = term_list()
    call filter(l:terms, 'bufwinid(v:val) isnot# -1 && term_getstatus(v:val) =~# "running"')
  endif

  if empty(l:terms)
    return
  endif

  let l:term = l:terms[0]
  call term_sendkeys(l:term, a:expr)
  let l:win = bufwinnr(l:term)
  exec l:win 'wincmd w'
  return win_getid(l:win)
endfunction

function simpl#load(...) abort
  if s:should_do_load()
    let l:file = expand('%')
    let l:code = s:simpl()[&filetype]['buildloadexpr'](l:file)
    return call(function('s:do_load'), [l:code] + a:000)
  endif
  return 0
endfunction

function simpl#prompt_and_load(...) abort
  if s:should_do_load()
    let l:text = s:simpl()[&filetype]['getprompttext']()
    let l:file = input(l:text, expand('%'), 'file')
    let l:code = s:simpl()[&filetype]['buildloadexpr'](l:file)
    return call(function('s:do_load'), [l:code] + a:000)
  endif
  return 0
endfunction

function simpl#register(filetype, BuildLoadExpr, GetPromptText) abort
  let g:simpl = s:simpl()
  let g:simpl[a:filetype] = {
        \ 'buildloadexpr': a:BuildLoadExpr,
        \ 'getprompttext': a:GetPromptText
        \ }
endfunction

function s:mods() abort
  return get(b:, 'simpl_mods', get(g:, 'simpl_mods', ''))
endfunction
