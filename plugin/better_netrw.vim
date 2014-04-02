if exists('g:loaded_better_netrw') || &cp
  finish
endif

let s:script_dir = expand('<sfile>:p:h')

let g:loaded_better_netrw = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

command! -nargs=* -complete=dir BetterNetrw call s:BetterNetrw(<f-args>)

function! s:BetterNetrw(...)
  if a:0 > 0
    let dir = a:1
  else
    let dir = '.'
  endif

  exe 'cd '.dir

  let files = split(glob('*'), "\n")

  let icon_width      = 20
  let line_item_count = winwidth(0) / icon_width
  let line_height     = 10

  tabnew
  let canvas_height = (len(files) / line_item_count) * line_height
  call append(0, repeat([''], canvas_height))
  normal! gg
  set filetype=better_netrw
  setlocal nowrap

  let index = 0
  for filename in files
    if isdirectory(filename)
      let template = s:Template('directory')
    else
      let template = s:Template('text')
    endif

    let line = 1 + (index / line_item_count) * line_height
    let col  = (index % line_item_count) * icon_width

    call s:PasteAtPosition(line, col, template."\n".s:FormatFilename(filename, icon_width))
    let index += 1
  endfor

  set nomodified
endfunction

function! s:PasteAtPosition(line, col, text)
  let [line, col, text] = [a:line, a:col, a:text]

  setlocal virtualedit=all

  try
    let saved_view = winsaveview()
    let pos = getpos('.')
    let pos[1] = line
    let pos[2] = col
    call setpos('.', pos)

    call setreg('z', text, 'b')
    normal! "zP

  finally
    call winrestview(saved_view)
  endtry
endfunction

function! s:Template(name)
  return join(readfile(s:script_dir.'/../templates/'.a:name), "\n")
endfunction

function! s:FormatFilename(filename, width)
  let filename = a:filename
  let width    = a:width

  if len(filename) > width
    return strpart(filename, 0, width - 1).'…'
  else
    let padding = repeat(' ', (width - len(filename)) / 2)
    return padding.filename.padding
  endif
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
