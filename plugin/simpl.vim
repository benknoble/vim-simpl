if get(g:, 'simpl_no_defaults', v:false)
  finish
endif

function s:sml_load(file) abort
  let l:cm = glob(fnamemodify(a:file, ':h').'/*.cm', v:false, v:true)
  if len(l:cm)
    return printf("CM.make \"%s\";\n", l:cm[0])
  else
    return printf("use \"%s\";\n", a:file)
  endif
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
