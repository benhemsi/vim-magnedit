" Vim global plugin for long-range editing
" Last Change:	2020 Aug 8
" Maintainer:	Ben Hemsi <github.com/benhemsi>
" License:	This file is placed in the public domain
                                                   
if exists("g:loaded_magnedit")
  finish
endif
let g:loaded_magnedit = 1

function! s:EditCodeWithNormalMode(count,editCommand)
    norm mz
    let lineToMoveTo = s:GetTargetLine(line(".") + a:count)
    call cursor(lineToMoveTo,0)
    execute "norm " . a:editCommand
    norm `z
    delm z
endfunction

function! s:EditCodeFromCurrentPosition(count,selection,editCommand)
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

nnoremap <silent> <Plug>MagneditDeleteLineDown             :<C-U>call <SID>EditCodeWithNormalMode(v:count, "dd")<CR>
nnoremap <silent> <Plug>MagneditDeleteLineUp               :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "dd")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphDown        :<C-U>call <SID>EditCodeWithNormalMode(v:count, "dap")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphUp          :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "dap")<CR>
nnoremap <silent> <Plug>MagneditYankLineDown               :<C-U>call <SID>EditCodeWithNormalMode(v:count, "yy")<CR>
nnoremap <silent> <Plug>MagneditYankLineUp                 :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "yy")<CR>
nnoremap <silent> <Plug>MagneditYankParagraphDown          :<C-U>call <SID>EditCodeWithNormalMode(v:count, "yap")<CR>
nnoremap <silent> <Plug>MagneditYankParagraphUp            :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "yap")<CR>
nnoremap <silent> <Plug>MagneditDeleteInnerSelectionDown   :<C-U>call <SID>EditCodeWithNormalMode(v:count, "di" . getcharstr())<CR>
nnoremap <silent> <Plug>MagneditDeleteInnerSelectionUp     :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "di" . getcharstr())<CR>
nnoremap <silent> <Plug>MagneditDeleteAroundSelectionDown  :<C-U>call <SID>EditCodeWithNormalMode(v:count, "da" . getcharstr())<CR>
nnoremap <silent> <Plug>MagneditDeleteAroundSelectionUp    :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "da" . getcharstr())<CR>
nnoremap <silent> <Plug>MagneditYankInnerSelectionDown     :<C-U>call <SID>EditCodeWithNormalMode(v:count, "yi" . getcharstr())<CR>
nnoremap <silent> <Plug>MagneditYankInnerSelectionUp       :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "yi" . getcharstr())<CR>
nnoremap <silent> <Plug>MagneditYankAroundSelectionDown    :<C-U>call <SID>EditCodeWithNormalMode(v:count, "ya" . getcharstr())<CR>
nnoremap <silent> <Plug>MagneditYankAroundSelectionUp      :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "ya" . getcharstr())<CR>
                                                                                                           
nnoremap <silent> <Plug>MagneditInsertEmptyLineDown        :<C-U>call <SID>EditCodeWithNormalMode(v:count, "line", "o")<CR>
nnoremap <silent> <Plug>MagneditInsertEmptyLineUp          :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "line", "O")<CR>
nnoremap <silent> <Plug>MagneditPasteDown                  :<C-U>call <SID>EditCodeWithNormalMode(v:count, "line", "p")<CR>
nnoremap <silent> <Plug>MagneditPasteUp                    :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "line", "P")<CR>
                                                                                                           
nnoremap <silent> <Plug>MagneditCommentLineDown            :<C-U>call <SID>EditCodeWithNormalMode(v:count, "gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentLineUp              :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphDown       :<C-U>call <SID>EditCodeWithNormalMode(v:count, "gcap")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphUp         :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "gcap")<CR>

nnoremap <silent> <Plug>MagneditMoveCurrentLineDown        :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "line", "m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentLineUp          :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count, "line", "m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphDown   :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "outerparagraph", "m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphUp     :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count, "outerparagraph", "m")<CR>
                                                                      
nnoremap <silent> <Plug>MagneditCopyCurrentLineDown        :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "line", "co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentLineUp          :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count-1, "line", "co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphDown   :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "outerparagraph", "co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphUp     :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count-1, "outerparagraph", "co")<CR>
                                                                      
vnoremap <silent> <Plug>MagneditMoveVisualDown             :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "visual", "m")<CR>
vnoremap <silent> <Plug>MagneditMoveVisualUp               :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count-1, "visual", "m")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualDown             :<C-U>call <SID>EditCodeFromCurrentPosition(v:count, "visual", "co")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualUp               :<C-U>call <SID>EditCodeFromCurrentPosition(-v:count-1, "visual", "co")<CR>

if !exists("g:magnedit_no_mappings") || ! g:magnedit_no_mappings
    nmap dJ           <Plug>MagneditDeleteLineDown      
    nmap dK           <Plug>MagneditDeleteLineUp        
    nmap d]           <Plug>MagneditDeleteParagraphDown 
    nmap d[           <Plug>MagneditDeleteParagraphUp 
    nmap yJ           <Plug>MagneditYankLineDown        
    nmap yK           <Plug>MagneditYankLineUp          
    nmap y]           <Plug>MagneditYankParagraphDown   
    nmap y[           <Plug>MagneditYankParagraphUp     
    nnoremap <silent> dij      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "di" . getcharstr())<CR>
    nnoremap <silent> dik      :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "di" . getcharstr())<CR>  
    nnoremap <silent> daj      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "da" . getcharstr())<CR>
    nnoremap <silent> dak      :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "da" . getcharstr())<CR>  
    nnoremap <silent> yij      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "yi" . getcharstr())<CR>
    nnoremap <silent> yik      :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "yi" . getcharstr())<CR>  
    nnoremap <silent> yaj      :<C-U>call <SID>EditCodeWithNormalMode(v:count, "ya" . getcharstr())<CR>
    nnoremap <silent> yak      :<C-U>call <SID>EditCodeWithNormalMode(-v:count, "ya" . getcharstr())<CR>  

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

