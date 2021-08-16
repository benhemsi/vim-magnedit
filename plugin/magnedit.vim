" Vim global plugin for long-range editing
" Last Change:	2020 Aug 8
" Maintainer:	Ben Hemsi <github.com/benhemsi>
" License:	This file is placed in the public domain
                                                   
if exists("g:loaded_magnedit")
  finish
endif
let g:loaded_magnedit = 1

function! s:EditCodeWithNormalMode(count,upOrDown,editCommand)
    norm mz
    if a:upOrDown ==? "UP" 
        let lineToMoveTo = s:GetTargetLine(line(".") - a:count)
    elseif a:upOrDown ==? "DOWN"
        let lineToMoveTo = s:GetTargetLine(line(".") + a:count)
    endif
    call cursor(lineToMoveTo,0)
    execute "norm " . a:editCommand
    norm `z
    delm z
endfunction

function! s:EditCodeFromCurrentPosition(count,upOrDown,selection,editCommand)
    if a:selection ==? "LINE"
        let codeToEdit = line(".")
    elseif a:selection ==? "INNERPARAGRAPH"
        let codeToEdit = s:GetParagraphRange(line("."),"inner")
    elseif a:selection ==? "OUTERPARAGRAPH"
        let codeToEdit = s:GetParagraphRange(line("."),"outer")
    elseif a:selection ==? "VISUAL"
        let codeToEdit = "'<,'>"
    endif
    if a:upOrDown ==? "UP"
        let endLocation = " " . (s:GetTargetLine(line(".") - a:count) - 1)
    else
        let endLocation = " " . s:GetTargetLine(line(".") + a:count)
    endif
    execute ":" . codeToEdit . a:editCommand . endLocation
endfunction

function! s:GetParagraphRange(line,innerOrOuter)
    norm mz
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
    norm `z
    delm z
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

nnoremap <silent> <Plug>MagneditDeleteLineDown             :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "dd")<CR>
nnoremap <silent> <Plug>MagneditDeleteLineUp               :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "dd")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphDown        :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "dap")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphUp          :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "dap")<CR>
nnoremap <silent> <Plug>MagneditYankLineDown               :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "yy")<CR>
nnoremap <silent> <Plug>MagneditYankLineUp                 :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "yy")<CR>
nnoremap <silent> <Plug>MagneditYankParagraphDown          :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "yap")<CR>
nnoremap <silent> <Plug>MagneditYankParagraphUp            :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "yap")<CR>
nnoremap <silent> <Plug>MagneditDeleteInnerSelectionDown   :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "di" . nr2char(getchar()))<CR>
nnoremap <silent> <Plug>MagneditDeleteInnerSelectionUp     :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "di" . nr2char(getchar()))<CR>
nnoremap <silent> <Plug>MagneditDeleteAroundSelectionDown  :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "da" . nr2char(getchar()))<CR>
nnoremap <silent> <Plug>MagneditDeleteAroundSelectionUp    :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "da" . nr2char(getchar()))<CR>
nnoremap <silent> <Plug>MagneditYankInnerSelectionDown     :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "yi" . nr2char(getchar()))<CR>
nnoremap <silent> <Plug>MagneditYankInnerSelectionUp       :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "yi" . nr2char(getchar()))<CR>
nnoremap <silent> <Plug>MagneditYankAroundSelectionDown    :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "ya" . nr2char(getchar()))<CR>
nnoremap <silent> <Plug>MagneditYankAroundSelectionUp      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "ya" . nr2char(getchar()))<CR>
                                                                                                           
nnoremap <silent> <Plug>MagneditInsertEmptyLineDown        :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "line", "o")<CR>
nnoremap <silent> <Plug>MagneditInsertEmptyLineUp          :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "line", "O")<CR>
nnoremap <silent> <Plug>MagneditPasteDown                  :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "line", "p")<CR>
nnoremap <silent> <Plug>MagneditPasteUp                    :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "line", "P")<CR>
                                                                                                           
nnoremap <silent> <Plug>MagneditCommentLineDown            :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentLineUp              :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphDown       :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "gcap")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphUp         :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "gcap")<CR>

nnoremap <silent> <Plug>MagneditMoveCurrentLineDown        :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "down", "line", "m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentLineUp          :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "up", "line", "m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphDown   :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "down", "outerparagraph", "m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphUp     :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "up", "outerparagraph", "m")<CR>
                                                                      
nnoremap <silent> <Plug>MagneditCopyCurrentLineDown        :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "down", "line", "co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentLineUp          :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "up", "line", "co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphDown   :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "down", "outerparagraph", "co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphUp     :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "up", "outerparagraph", "co")<CR>
                                                                      
vnoremap <silent> <Plug>MagneditMoveVisualDown             :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "down", "visual", "m")<CR>
vnoremap <silent> <Plug>MagneditMoveVisualUp               :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "up", "visual", "m")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualDown             :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "down", "visual", "co")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualUp               :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "up", "visual", "co")<CR>

if !exists("g:magnedit_no_mappings") || ! g:magnedit_no_mappings
    nmap dJ           <Plug>MagneditDeleteLineDown      
    nmap dK           <Plug>MagneditDeleteLineUp        
    nmap d]           <Plug>MagneditDeleteParagraphDown 
    nmap d[           <Plug>MagneditDeleteParagraphUp 
    nmap yJ           <Plug>MagneditYankLineDown        
    nmap yK           <Plug>MagneditYankLineUp          
    nmap y]           <Plug>MagneditYankParagraphDown   
    nmap y[           <Plug>MagneditYankParagraphUp     
    nnoremap <silent> dij      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "di" . nr2char(getchar()))<CR>
    nnoremap <silent> dik      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "di" . nr2char(getchar()))<CR>  
    nnoremap <silent> daj      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "da" . nr2char(getchar()))<CR>
    nnoremap <silent> dak      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "da" . nr2char(getchar()))<CR>  
    nnoremap <silent> yij      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "yi" . nr2char(getchar()))<CR>
    nnoremap <silent> yik      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "yi" . nr2char(getchar()))<CR>  
    nnoremap <silent> yaj      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "down", "ya" . nr2char(getchar()))<CR>
    nnoremap <silent> yak      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "up", "ya" . nr2char(getchar()))<CR>  

    nmap <leader>o    <Plug>MagneditInsertEmptyLineDown 
    nmap <leader>O    <Plug>MagneditInsertEmptyLineUp   
    nmap <leader>p    <Plug>MagneditPasteDown
    nmap <leader>P    <Plug>MagneditPasteUp  

    nmap gcJ          <Plug>MagneditCommentLineDown     
    nmap gcK          <Plug>MagneditCommentLineUp       
    nmap gc]          <Plug>MagneditCommentParagraphDown                                     
    nmap gc[          <Plug>MagneditCommentParagraphUp  

    nmap mvJ          <Plug>MagneditMoveCurrentLineDown       
    nmap mvK          <Plug>MagneditMoveCurrentLineUp       
    nmap mv]          <Plug>MagneditMoveCurrentParagraphDown
    nmap mv[          <Plug>MagneditMoveCurrentParagraphUp              
                                                           
    nmap cpJ          <Plug>MagneditCopyCurrentLineDown     
    nmap cpK          <Plug>MagneditCopyCurrentLineUp       
    nmap cp]          <Plug>MagneditCopyCurrentParagraphDown                                        
    nmap cp[          <Plug>MagneditCopyCurrentParagraphUp                                        
                                   
    vmap mvJ          <Plug>MagneditMoveVisualDown    
    vmap mvK          <Plug>MagneditMoveVisualUp        
    vmap cpJ          <Plug>MagneditCopyVisualDown      
    vmap cpK          <Plug>MagneditCopyVisualUp        
endif                                            

