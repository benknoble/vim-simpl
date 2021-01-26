if get(g:, 'simpl_no_defaults', v:false)
  finish
endif

function s:simplify(path) abort
  " ripped from ale#paths#Simplify
  if has('unix')
    let l:unix_path = substitute(a:path, '\\', '/', 'g')
    return substitute(simplify(l:unix_path), '^//\+', '/', 'g') " no-custom-checks
  else
    let l:win_path = substitute(a:path, '/', '\\', 'g')
    return substitute(simplify(l:win_path), '^\\\+', '\', 'g') " no-custom-checks
  endif
endfunction

function s:upwards_parts(path) abort
  " ripped from ale#path#Upwards
  let l:pattern = has('win32') ? '\v/+|\\+' : '\v/+'
  let l:sep = has('win32') ? '\' : '/'
  let l:parts = split(s:simplify(a:path), l:pattern)
  let l:path_list = range(1, len(l:parts))->map({_, v -> join(l:parts[:-v], l:sep)})

  if has('win32') && a:path =~# '^[a-zA-z]:\'
    " Add \ to C: for C:\, etc.
    let l:path_list[-1] .= '\'
  elseif a:path[0] is# '/'
    " If the path starts with /, even on Windows, add / and / to all paths.
    call map(l:path_list, "'/' . v:val")
    call add(l:path_list, '/')
  endif

  return l:path_list
endfunction

function s:sml_load(file) abort
  for l:path in s:upwards_parts(fnamemodify(a:file, ':p:h'))
    let l:cm = glob(printf('%s/%s', l:path, '*.cm'), v:false, v:true)
    if len(l:cm)
      return printf("CM.make \"%s\";\n", l:cm[0])
    endif
  endfor
  return printf("use \"%s\";\n", a:file)
endfunction

call simpl#register(
      \ 'sml',
      \ funcref('s:sml_load'),
      \ {-> 'use '})

function s:lisp_load(file) abort
  " double-quotes necessary for \n expansion
  return printf("(load #P\"%s\")\n", a:file)
endfunction

call simpl#register(
      \ 'lisp',
      \ funcref('s:lisp_load'),
      \ {-> '(load) '})

call simpl#register(
      \ 'sh',
      \ {f -> printf("source %s\n", f)},
      \ {-> 'source '})

call simpl#register(
      \ 'clojure',
      \ {s -> printf("(load-file \"%s\")\n", s)},
      \ {-> '(require) '})

call simpl#register(
      \ 'prolog',
      \ {s -> printf("[\"%s\"].\n", fnamemodify(s, ':r'))},
      \ {-> '?- '})

call simpl#register(
      \ 'racket',
      \ {s -> printf(",require-reloadable %s\n", s)},
      \ {-> ',require-reloadable '})
