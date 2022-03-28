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

function! s:editCode(count,editCommand,repeatMapping)
  let startingPosition = getcurpos()
  let lineToMoveTo = s:getTargetLine(line(".") + a:count)
  call cursor(lineToMoveTo,0)
  execute a:editCommand
  call cursor(startingPosition[1], startingPosition[2])
  silent! call repeat#set("\<Plug>Magnedit" . a:repeatMapping, v:count)
endfunction

function! s:editCodeFromCurrentPosition(count,selection,editCommand,repeatMapping)
  let startingPosition = getcurpos()
  if a:selection ==? "LINE"
    let codeToEdit = line(".")
  elseif a:selection ==? "INNERPARAGRAPH"
    let codeToEdit = s:getParagraphRange("inner")
  elseif a:selection ==? "OUTERPARAGRAPH"
    let codeToEdit = s:getParagraphRange("outer")
  elseif a:selection ==? "VISUAL"
    let codeToEdit = "'<,'>"
  endif
  let endLocation = " " . s:getTargetLine(line(".") + a:count)
  execute ":" . codeToEdit . a:editCommand . endLocation
  call cursor(startingPosition[1], startingPosition[2])
  silent! call repeat#set("\<Plug>Magnedit" . a:repeatMapping, v:count)
endfunction

function! s:editCodeWithParameter(count,editCommand,repeatMapping)
  let object = getcharstr()
  let startingPosition = getcurpos()
  let lineToMoveTo = s:getTargetLine(line(".") + a:count)
  call cursor(lineToMoveTo,0)
  execute "norm f" . object
  execute a:editCommand . object
  call cursor(startingPosition[1], startingPosition[2])
  silent! call repeat#set("\<Plug>Magnedit" . a:repeatMapping, v:count)
endfunction

function! s:getParagraphRange(innerOrOuter)
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
  return startLine . "," . endLine
endfunction

function! s:getTargetLine(line)
  if a:line < 1
    return 1
  elseif a:line > line("$")
    return line("$")
  else
    return a:line
  endif
endfunction

nnoremap <Plug>MagneditDeleteLineDown                 <Cmd>call <SID>editCode(v:count, "d " . g:magnedit_delete_register, "DeleteLineDown")<CR>
nnoremap <Plug>MagneditDeleteLineUp                   <Cmd>call <SID>editCode(-v:count, "d " . g:magnedit_delete_register, "DeleteLineUp")<CR>
nnoremap <Plug>MagneditDeleteParagraphDown            <Cmd>call <SID>editCode(v:count, 'norm "' . g:magnedit_delete_register . 'dap', "DeleteParagraphDown")<CR>
nnoremap <Plug>MagneditDeleteParagraphUp              <Cmd>call <SID>editCode(-v:count, 'norm "' . g:magnedit_delete_register . 'dap', "DeleteParagraphUp")<CR>

nnoremap <Plug>MagneditYankLineDown                   <Cmd>call <SID>editCode(v:count, "y " . g:magnedit_yank_register, "YankLineDown")<CR>
nnoremap <Plug>MagneditYankLineUp                     <Cmd>call <SID>editCode(-v:count, "y " . g:magnedit_yank_register, "YankLineUp")<CR>
nnoremap <Plug>MagneditYankParagraphDown              <Cmd>call <SID>editCode(v:count, 'norm "' . g:magnedit_yank_register . 'yap', "YankParagraphDown")<CR>
nnoremap <Plug>MagneditYankParagraphUp                <Cmd>call <SID>editCode(-v:count, 'norm "' . g:magnedit_yank_register . 'yap', "YankParagraphUp")<CR>

nnoremap <Plug>MagneditInsertEmptyLineDown            <Cmd>call <SID>editCode(v:count, "pu _", "InsertEmptyLineDown")<CR>
nnoremap <Plug>MagneditInsertEmptyLineUp              <Cmd>call <SID>editCode(-v:count, "pu! _", "InsertEmptyLineUp")<CR>
nnoremap <Plug>MagneditPasteDown                      <Cmd>call <SID>editCode(v:count, "pu", "PasteDown")<CR>
nnoremap <Plug>MagneditPasteUp                        <Cmd>call <SID>editCode(-v:count, "pu!", "PasteUp")<CR>

nnoremap <Plug>MagneditCommentLineDown                <Cmd>call <SID>editCode(v:count, "norm gcc", "CommentLineDown")<CR>
nnoremap <Plug>MagneditCommentLineUp                  <Cmd>call <SID>editCode(-v:count, "norm gcc", "CommentLineUp")<CR>
nnoremap <Plug>MagneditCommentParagraphDown           <Cmd>call <SID>editCode(v:count, "norm gcip", "CommentParagraphDown")<CR>
nnoremap <Plug>MagneditCommentParagraphUp             <Cmd>call <SID>editCode(-v:count, "norm gcip", "CommentParagraphUp")<CR>

nnoremap <Plug>MagneditMoveCurrentLineDown            <Cmd>call <SID>editCodeFromCurrentPosition(v:count1, "line", "m", "MoveCurrentLineDown")<CR>
nnoremap <Plug>MagneditMoveCurrentLineUp              <Cmd>call <SID>editCodeFromCurrentPosition(-v:count1-1, "line", "m", "MoveCurrentLineUp")<CR>
nnoremap <Plug>MagneditMoveCurrentParagraphDown       <Cmd>call <SID>editCodeFromCurrentPosition(v:count1, "outerparagraph", "m", "MoveCurrentParagraphDown")<CR>
nnoremap <Plug>MagneditMoveCurrentParagraphUp         <Cmd>call <SID>editCodeFromCurrentPosition(-v:count1-1, "outerparagraph", "m", "MoveCurrentParagraphUp")<CR>

nnoremap <Plug>MagneditCopyCurrentLineDown            <Cmd>call <SID>editCodeFromCurrentPosition(v:count, "line", "co", "CopyCurrentLineDown")<CR>
nnoremap <Plug>MagneditCopyCurrentLineUp              <Cmd>call <SID>editCodeFromCurrentPosition(-v:count-1, "line", "co", "CopyCurrentLineUp")<CR>
nnoremap <Plug>MagneditCopyCurrentParagraphDown       <Cmd>call <SID>editCodeFromCurrentPosition(v:count, "outerparagraph", "co", "CopyCurrentParagraphDown")<CR>
nnoremap <Plug>MagneditCopyCurrentParagraphUp         <Cmd>call <SID>editCodeFromCurrentPosition(-v:count-1, "outerparagraph", "co", "CopyCurrentParagraphUp")<CR>

vnoremap <Plug>MagneditMoveVisualDown                 :<C-U>call <SID>editCodeFromCurrentPosition(v:count1, "visual", "m", "MoveVisualDown")<CR>
vnoremap <Plug>MagneditMoveVisualUp                   :<C-U>call <SID>editCodeFromCurrentPosition(-v:count1-1, "visual", "m", "MoveVisualUp")<CR>
vnoremap <Plug>MagneditCopyVisualDown                 :<C-U>call <SID>editCodeFromCurrentPosition(v:count1, "visual", "co", "CopyVisualDown")<CR>
vnoremap <Plug>MagneditCopyVisualUp                   :<C-U>call <SID>editCodeFromCurrentPosition(-v:count1-1, "visual", "co", "CopyVisualUp")<CR>

nnoremap <Plug>MagneditDeleteInnerObjectDown          <Cmd>call <SID>editCodeWithParameter(v:count, 'norm "' . g:magnedit_delete_register . 'di', "DeleteInnerObjectDown")<CR>
nnoremap <Plug>MagneditDeleteAObjectDown              <Cmd>call <SID>editCodeWithParameter(v:count, 'norm "' . g:magnedit_delete_register . 'da', "DeleteAObjectDown")<CR>
nnoremap <Plug>MagneditDeleteInnerObjectUp            <Cmd>call <SID>editCodeWithParameter(-v:count, 'norm "' . g:magnedit_delete_register . 'di', "DeleteInnerObjectUp")<CR>
nnoremap <Plug>MagneditDeleteAObjectUp                <Cmd>call <SID>editCodeWithParameter(-v:count, 'norm "' . g:magnedit_delete_register . 'da', "DeleteAObjectUp")<CR>

nnoremap <Plug>MagneditYankInnerObjectDown            <Cmd>call <SID>editCodeWithParameter(v:count, 'norm "' . g:magnedit_yank_register . 'yi', "YankInnerObjectDown")<CR>
nnoremap <Plug>MagneditYankAObjectDown                <Cmd>call <SID>editCodeWithParameter(v:count, 'norm "' . g:magnedit_yank_register . 'ya', "YankAObjectDown")<CR>
nnoremap <Plug>MagneditYankInnerObjectUp              <Cmd>call <SID>editCodeWithParameter(-v:count, 'norm "' . g:magnedit_yank_register . 'yi', "YankInnerObjectUp")<CR>
nnoremap <Plug>MagneditYankAObjectUp                  <Cmd>call <SID>editCodeWithParameter(-v:count, 'norm "' . g:magnedit_yank_register . 'ya', "YankAObjectUp")<CR>

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

