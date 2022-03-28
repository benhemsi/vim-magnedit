" Vim global plugin for long-range editing
" Last Change:	2020 Aug 8
" Maintainer:	Ben Hemsi <github.com/benhemsi>
" License:	This file is placed in the public domain

if exists("g:loaded_magnedit")
  finish
endif
let g:loaded_magnedit = 1

let g:magnedit_yank_register = get(g:, 'magnedit_yank_register', "m")
let g:magnedit_delete_register = get(g:, 'magnedit_delete_register', "n")

function! s:EditCode(count,editCommand)
  let startingPosition = getcurpos()
  let lineToMoveTo = s:GetTargetLine(line(".") + a:count)
  call cursor(lineToMoveTo,0)
  execute a:editCommand
  call cursor(startingPosition[1], startingPosition[2])
endfunction

function! s:EditCodeWithParameter(count,editCommand)
  let object = getcharstr()
  let startingPosition = getcurpos()
  let lineToMoveTo = s:GetTargetLine(line(".") + a:count)
  call cursor(lineToMoveTo,0)
  execute "norm f" . object
  execute a:editCommand . object
  call cursor(startingPosition[1], startingPosition[2])
endfunction

function! s:EditCodeFromCurrentPosition(count,selection,editCommand)
  let startingPosition = getcurpos()
  if a:selection ==? "LINE"
    let codeToEdit = line(".")
  elseif a:selection ==? "INNERPARAGRAPH"
    let codeToEdit = s:GetParagraphRange(line("."),"inner")
  elseif a:selection ==? "OUTERPARAGRAPH"
    let codeToEdit = s:GetParagraphRange(line("."),"outer")
  elseif a:selection ==? "VISUAL"
    let codeToEdit = "'<,'>"
  endif
  let endLocation = " " . s:GetTargetLine(line(".") + a:count)
  execute ":" . codeToEdit . a:editCommand . endLocation
  call cursor(startingPosition[1], startingPosition[2])
endfunction

function! s:GetParagraphRange(line,innerOrOuter)
  let startingPosition = getcurpos()
  call cursor(a:line,0)
  let startLineIsStart = (line("'{") == 1)
  let lastLineIsEnd = (line("'}") == line("$"))
  if startLineIsStart && lastLineIsEnd
    let startLine = line("'{")
    let endLine = line("'}")
  elseif startLineIsStart
    let startLine = line("'{")
    if a:innerOrOuter ==? "INNER"
      let endLine = line("'}") - 1
    else
      let endLine = line("'}")
    endif
  elseif lastLineIsEnd
    let endLine = line("'}")
    if a:innerOrOuter ==? "INNER"
      let startLine = line("'{") + 1
    else
      let startLine = line("'{")
    endif
  else
    let startLine = line("'{") + 1
    if a:innerOrOuter ==? "INNER"
      let endLine = line("'}") - 1
    else
      let endLine = line("'}")
    endif
  endif
  call cursor(startingPosition[1], startingPosition[2])
  return startLine . "," . endLine
endfunction

function! s:GetTargetLine(line)
  if a:line < 1
    return 1
  elseif a:line > line("$")
    return line("$")
  else
    return a:line
  endif
endfunction

nnoremap <Plug>MagneditDeleteLineDown                 <Cmd>call <SID>EditCode(v:count, "d " . g:magnedit_delete_register)<CR>
nnoremap <Plug>MagneditDeleteLineUp                   <Cmd>call <SID>EditCode(-v:count, "d " . g:magnedit_delete_register)<CR>
nnoremap <Plug>MagneditDeleteParagraphDown            <Cmd>call <SID>EditCode(v:count, 'norm "' . g:magnedit_delete_register . 'dap')<CR>
nnoremap <Plug>MagneditDeleteParagraphUp              <Cmd>call <SID>EditCode(-v:count, 'norm "' . g:magnedit_delete_register . 'dap')<CR>
nnoremap <Plug>MagneditYankLineDown                   <Cmd>call <SID>EditCode(v:count, "y " . g:magnedit_yank_register)<CR>
nnoremap <Plug>MagneditYankLineUp                     <Cmd>call <SID>EditCode(-v:count, "y " . g:magnedit_yank_register)<CR>
nnoremap <Plug>MagneditYankParagraphDown              <Cmd>call <SID>EditCode(v:count, 'norm "' . g:magnedit_yank_register . 'yap')<CR>
nnoremap <Plug>MagneditYankParagraphUp                <Cmd>call <SID>EditCode(-v:count, 'norm "' . g:magnedit_yank_register . 'yap')<CR>

nnoremap <Plug>MagneditInsertEmptyLineDown            <Cmd>call <SID>EditCode(v:count, "pu _")<CR>
nnoremap <Plug>MagneditInsertEmptyLineUp              <Cmd>call <SID>EditCode(-v:count, "pu! _")<CR>
nnoremap <Plug>MagneditPasteDown                      <Cmd>call <SID>EditCode(v:count, "pu")<CR>
nnoremap <Plug>MagneditPasteUp                        <Cmd>call <SID>EditCode(-v:count, "pu!")<CR>

nnoremap <Plug>MagneditDeleteInnerObjectDown          <Cmd>call <SID>EditCodeWithParameter(v:count, 'norm "' . g:magnedit_delete_register . 'di')<CR>
nnoremap <Plug>MagneditDeleteAObjectDown              <Cmd>call <SID>EditCodeWithParameter(v:count, 'norm "' . g:magnedit_delete_register . 'da')<CR>
nnoremap <Plug>MagneditDeleteInnerObjectUp            <Cmd>call <SID>EditCodeWithParameter(-v:count, 'norm "' . g:magnedit_delete_register . 'di')<CR>
nnoremap <Plug>MagneditDeleteAObjectUp                <Cmd>call <SID>EditCodeWithParameter(-v:count, 'norm "' . g:magnedit_delete_register . 'da')<CR>
nnoremap <Plug>MagneditYankInnerObjectDown            <Cmd>call <SID>EditCodeWithParameter(v:count, 'norm "' . g:magnedit_yank_register . 'yi')<CR>
nnoremap <Plug>MagneditYankAObjectDown                <Cmd>call <SID>EditCodeWithParameter(v:count, 'norm "' . g:magnedit_yank_register . 'ya')<CR>
nnoremap <Plug>MagneditYankInnerObjectUp              <Cmd>call <SID>EditCodeWithParameter(-v:count, 'norm "' . g:magnedit_yank_register . 'yi')<CR>
nnoremap <Plug>MagneditYankAObjectUp                  <Cmd>call <SID>EditCodeWithParameter(-v:count, 'norm "' . g:magnedit_yank_register . 'ya')<CR>

nnoremap <Plug>MagneditCommentLineDown                <Cmd>call <SID>EditCode(v:count, "norm gcc")<CR>
nnoremap <Plug>MagneditCommentLineUp                  <Cmd>call <SID>EditCode(-v:count, "norm gcc")<CR>
nnoremap <Plug>MagneditCommentParagraphDown           <Cmd>call <SID>EditCode(v:count, "norm gcip")<CR>
nnoremap <Plug>MagneditCommentParagraphUp             <Cmd>call <SID>EditCode(-v:count, "norm gcip")<CR>

nnoremap <Plug>MagneditMoveCurrentLineDown            <Cmd>call <SID>EditCodeFromCurrentPosition(v:count1, "line", "m")<CR>
nnoremap <Plug>MagneditMoveCurrentLineUp              <Cmd>call <SID>EditCodeFromCurrentPosition(-v:count1-1, "line", "m")<CR>
nnoremap <Plug>MagneditMoveCurrentParagraphDown       <Cmd>call <SID>EditCodeFromCurrentPosition(v:count1, "outerparagraph", "m")<CR>
nnoremap <Plug>MagneditMoveCurrentParagraphUp         <Cmd>call <SID>EditCodeFromCurrentPosition(-v:count1-1, "outerparagraph", "m")<CR>

nnoremap <Plug>MagneditCopyCurrentLineDown            <Cmd>call <SID>EditCodeFromCurrentPosition(v:count, "line", "co")<CR>
nnoremap <Plug>MagneditCopyCurrentLineUp              <Cmd>call <SID>EditCodeFromCurrentPosition(-v:count-1, "line", "co")<CR>
nnoremap <Plug>MagneditCopyCurrentParagraphDown       <Cmd>call <SID>EditCodeFromCurrentPosition(v:count, "outerparagraph", "co")<CR>
nnoremap <Plug>MagneditCopyCurrentParagraphUp         <Cmd>call <SID>EditCodeFromCurrentPosition(-v:count-1, "outerparagraph", "co")<CR>

vnoremap <Plug>MagneditMoveVisualDown                 :<C-U>call <SID>EditCodeFromCurrentPosition(v:count1, "visual", "m")<CR>
vnoremap <Plug>MagneditMoveVisualUp                   :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count1-1, "visual", "m")<CR>
vnoremap <Plug>MagneditCopyVisualDown                 :<C-U>call <SID>EditCodeFromCurrentPosition(v:count1, "visual", "co")<CR>
vnoremap <Plug>MagneditCopyVisualUp                   :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count1-1, "visual", "co")<CR>

if !exists("g:magnedit_no_mappings") || ! g:magnedit_no_mappings
  nmap dJ           <Plug>MagneditDeleteLineDown
  nmap dK           <Plug>MagneditDeleteLineUp
  nmap d]           <Plug>MagneditDeleteParagraphDown
  nmap d[           <Plug>MagneditDeleteParagraphUp
  nmap yJ           <Plug>MagneditYankLineDown
  nmap yK           <Plug>MagneditYankLineUp
  nmap y]           <Plug>MagneditYankParagraphDown
  nmap y[           <Plug>MagneditYankParagraphUp

  nmap <leader>o    <Plug>MagneditInsertEmptyLineDown
  nmap <leader>O    <Plug>MagneditInsertEmptyLineUp
  nmap <leader>p    <Plug>MagneditPasteDown
  nmap <leader>P    <Plug>MagneditPasteUp

  nmap gcJ          <Plug>MagneditCommentLineDown
  nmap gcK          <Plug>MagneditCommentLineUp
  nmap gc]          <Plug>MagneditCommentParagraphDown
  nmap gc[          <Plug>MagneditCommentParagraphUp

  nmap mvj          <Plug>MagneditMoveCurrentLineDown
  nmap mvk          <Plug>MagneditMoveCurrentLineUp
  nmap mv]          <Plug>MagneditMoveCurrentParagraphDown
  nmap mv[          <Plug>MagneditMoveCurrentParagraphUp

  nmap cpj          <Plug>MagneditCopyCurrentLineDown
  nmap cpk          <Plug>MagneditCopyCurrentLineUp
  nmap cp]          <Plug>MagneditCopyCurrentParagraphDown
  nmap cp[          <Plug>MagneditCopyCurrentParagraphUp

  vmap mvj          <Plug>MagneditMoveVisualDown
  vmap mvk          <Plug>MagneditMoveVisualUp
  vmap cpj          <Plug>MagneditCopyVisualDown
  vmap cpk          <Plug>MagneditCopyVisualUp

  if exists("g:magnedit_object_editing") && g:magnedit_object_editing
    nmap dij          <Plug>MagneditDeleteInnerObjectDown
    nmap daj          <Plug>MagneditDeleteAObjectDown
    nmap dik          <Plug>MagneditDeleteInnerObjectUp
    nmap dak          <Plug>MagneditDeleteAObjectUp
    nmap yij          <Plug>MagneditYankInnerObjectDown
    nmap yaj          <Plug>MagneditYankAObjectDown
    nmap yik          <Plug>MagneditYankInnerObjectUp
    nmap yak          <Plug>MagneditYankAObjectUp
  endif

endif

