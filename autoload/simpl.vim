function simpl#repl(...) abort
  let l:interpreter = get(b:, 'interpreter', &shell)
  let l:command = 'term'
  if a:0
    for l:opt in a:000
      let l:command .= printf(' %s', opt)
    endfor
  endif
  let l:command .= printf(' %s', l:interpreter)
  execute l:command
endfunction

function simpl#shell(...) abort
  if has_key(b:, 'interpreter')
    let [l:old_interpreter, b:interpreter] = [b:interpreter, '']
  endif
  call call('simpl#repl', a:000)
  if has_key(b:, 'interpreter')
    let b:interpreter = l:old_interpreter
  endif
endfunction

function s:simpl() abort
  return get(g:, 'simpl', {})
endfunction

function s:should_do_load() abort
  return has_key(s:simpl(), &filetype)
endfunction

function s:do_load(expr) abort
  let l:terms = term_list()
  if empty(term_list())
    call simpl#repl('++close')
    let l:terms = term_list()
  endif

  let l:term = l:terms[0]
  call term_sendkeys(l:term, a:expr)
  let l:win = bufwinnr(l:term)
  exec l:win 'wincmd w'
endfunction

function simpl#load() abort
  if s:should_do_load()
    let l:file = expand('%')
    let l:code = s:simpl()[&filetype]['buildloadexpr'](l:file)
    call s:do_load(l:code)
  endif
endfunction

function simpl#prompt_and_load() abort
  if s:should_do_load()
    let l:text = s:simpl()[&filetype]['getprompttext']()
    let l:file = input(l:text, expand('%'), 'file')
    let l:code = s:simpl()[&filetype]['buildloadexpr'](l:file)
    call s:do_load(l:code)
  endif
endfunction

function simpl#register(filetype, BuildLoadExpr, GetPromptText) abort
  let g:simpl = s:simpl()
  let g:simpl[a:filetype] = {
        \ 'buildloadexpr': a:BuildLoadExpr,
        \ 'getprompttext': a:GetPromptText
        \ }
endfunction
