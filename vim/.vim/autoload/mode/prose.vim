" vim:fdm=marker:fmr={{{,}}}:fdl=1:ts=4:sts=2:sw=2:ft=vim
"
" Prose Mode
"

function! mode#prose#init() abort
  " initialize reedes' plugins
  call lexical#init()
  call litecorrect#init()
  call pencil#init()
  call textobj#sentence#init()
  call textobj#quote#init({'educate': 0})

  " do not autocomplete dictionary
  let b:deoplete_ignore_sources = ['dictionary', 'around']

  " don't use folds
  setlocal nofoldenable
endfunction
