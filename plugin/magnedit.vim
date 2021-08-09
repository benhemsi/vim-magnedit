" Vim global plugin for long-range editing
" Last Change:	2020 Aug 8
" Maintainer:	Ben Hemsi <Bram@vim.org>
" License:	This file is placed in the public domain
                                                   
if exists("g:loaded_magnedit")
  finish
endif
let g:loaded_magnedit = 1

function! s:EditCode(count,upOrDown,selection,editCommand)
    norm mz
    if a:upOrDown ==? "UP"
        if a:selection ==? "LINE"
            let codeToEdit = line(".") - a:count
        elseif a:selection ==? "INNERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(line(".") - a:count,"inner")
        elseif a:selection ==? "OUTERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(line(".") - a:count,"outer")
        endif
    else
        if a:selection ==? "LINE"
            let codeToEdit = line(".") + a:count
        elseif a:selection ==? "INNERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(line(".") + a:count,"inner")
        elseif a:selection ==? "OUTERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(line(".") + a:count,"outer")
        endif
    endif
    execute ":" . codeToEdit . a:editCommand
    norm `z
endfunction

function! s:EditCodeWithNormalMode(count,upOrDown,editCommand)
    norm mz
    if a:upOrDown ==? "UP" 
        let lineToMoveTo = line(".")-a:count
    elseif a:upOrDown ==? "DOWN"
        let lineToMoveTo = line(".")+a:count
    endif
    call cursor(lineToMoveTo,0)
    execute "norm " . a:editCommand
    norm `z
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
        let endLocation = "-" . a:count
    else
        let endLocation = "+" . a:count
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
    return startLine . "," . endLine
endfunction

nnoremap <silent> <Plug>MagneditDeleteLineDown             :<C-U>call s:EditCode(v:count,"down","line","d")<CR>
nnoremap <silent> <Plug>MagneditDeleteLineUp               :<C-U>call s:EditCode(v:count,"up","line","d")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphDown        :<C-U>call s:EditCode(v:count,"down","outerparagraph","d")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphUp          :<C-U>call s:EditCode(v:count,"up","outerparagraph","d")<CR>
nnoremap <silent> <Plug>MagneditCopyLineDown               :<C-U>call s:EditCode(v:count,"down","line","y")<CR>
nnoremap <silent> <Plug>MagneditCopyLineUp                 :<C-U>call s:EditCode(v:count,"up","line","y")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphDown          :<C-U>call s:EditCode(v:count,"down","outerparagraph","y")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphUp            :<C-U>call s:EditCode(v:count,"up","outerparagraph","y")<CR>
nnoremap <silent> <Plug>MagneditInsertEmptyLineDown        :<C-U>call s:EditCode(v:count,"down","line","pu! _")<CR>
nnoremap <silent> <Plug>MagneditInsertEmptyLineUp          :<C-U>call s:EditCode(v:count,"up","line","pu! _")<CR>
nnoremap <silent> <Plug>MagneditPasteDown                  :<C-U>call s:EditCode(v:count,"down","line","pu")<CR>
nnoremap <silent> <Plug>MagneditPasteUp                    :<C-U>call s:EditCode(v:count,"up","line","pu")<CR>
nnoremap <silent> <Plug>MagneditCommentLineDown            :<C-U>call s:EditCodeWithNormalMode(v:count,"down","gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentLineUp              :<C-U>call s:EditCodeWithNormalMode(v:count,"up","gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphDown       :<C-U>call s:EditCodeWithNormalMode(v:count,"down","gcap")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphUp         :<C-U>call s:EditCodeWithNormalMode(v:count,"up","gcap")<CR>

nnoremap <silent> <Plug>MagneditMoveLineDownHere           :<C-U>call s:EditCode(v:count,"down","line","m.")<CR>
nnoremap <silent> <Plug>MagneditMoveLineUpHere             :<C-U>call s:EditCode(v:count,"up","line","m.")<CR>
nnoremap <silent> <Plug>MagneditMoveParagraphDownHere      :<C-U>call s:EditCode(v:count,"down","outerparagraph","m.")<CR>
nnoremap <silent> <Plug>MagneditMoveParagraphUpHere        :<C-U>call s:EditCode(v:count,"up","outerparagraph","m.")<CR>

nnoremap <silent> <Plug>MagneditCopyLineDownHere           :<C-U>call s:EditCode(v:count,"down","line","co.")<CR>
nnoremap <silent> <Plug>MagneditCopyLineUpHere             :<C-U>call s:EditCode(v:count,"up","line","co.")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphDownHere      :<C-U>call s:EditCode(v:count,"down","outerparagraph","co.")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphUpHere        :<C-U>call s:EditCode(v:count,"up","outerparagraph","co.")<CR>

nnoremap <silent> <Plug>MagneditMoveCurrentLineDown        :<C-U>call s:EditCodeFromCurrentPosition(v:count,"down","line","m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentLineUp          :<C-U>call s:EditCodeFromCurrentPosition(v:count,"up","line","m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphDown   :<C-U>call s:EditCodeFromCurrentPosition(v:count,"down","outerparagraph","m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphUp     :<C-U>call s:EditCodeFromCurrentPosition(v:count,"up","outerparagraph","m")<CR>
                                                            
nnoremap <silent> <Plug>MagneditCopyCurrentLineDown        :<C-U>call s:EditCodeFromCurrentPosition(v:count,"down","line","co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentLineUp          :<C-U>call s:EditCodeFromCurrentPosition(v:count,"up","line","co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphDown   :<C-U>call s:EditCodeFromCurrentPosition(v:count,"down","outerparagraph","co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphUp     :<C-U>call s:EditCodeFromCurrentPosition(v:count,"up","outerparagraph","co")<CR>

vnoremap <silent> <Plug>MagneditMoveVisualDown             :<C-U>call s:EditCodeFromCurrentPosition(v:count,"down","visual","m")<CR>
vnoremap <silent> <Plug>MagneditMoveVisualUp               :<C-U>call s:EditCodeFromCurrentPosition(v:count,"up","visual","m")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualDown             :<C-U>call s:EditCodeFromCurrentPosition(v:count,"down","visual","co")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualUp               :<C-U>call s:EditCodeFromCurrentPosition(v:count,"up","visual","co")<CR>

if !exists("g:magnedit_no_mappings") || ! g:magnedit_no_mappings
    nmap dJ           <Plug>MagneditDeleteLineDown      
    nmap dK           <Plug>MagneditDeleteLineUp        
    nmap d]           <Plug>MagneditDeleteParagraphDown 
    nmap d[           <Plug>MagneditDeleteParagraphUp 
    nmap yJ           <Plug>MagneditCopyLineDown        
    nmap yK           <Plug>MagneditCopyLineUp          
    nmap y]           <Plug>MagneditCopyParagraphDown   
    nmap y[           <Plug>MagneditCopyParagraphUp     
    nmap <leader>o    <Plug>MagneditInsertEmptyLineDown 
    nmap <leader>O    <Plug>MagneditInsertEmptyLineUp   
    nmap <leader>p    <Plug>MagneditPasteDown
    nmap <leader>P    <Plug>MagneditPasteUp  
    nmap gcJ          <Plug>MagneditCommentLineDown     
    nmap gcK          <Plug>MagneditCommentLineUp       
    nmap gc]          <Plug>MagneditCommentParagraphDown                                     
    nmap gc[          <Plug>MagneditCommentParagraphUp  

    nmap mvj          <Plug>MagneditMoveLineDownHere       
    nmap mvk          <Plug>MagneditMoveLineUpHere            
    nmap mv]          <Plug>MagneditMoveParagraphDownHere  
    nmap mv[          <Plug>MagneditMoveParagraphUpHere   
                                                 
    nmap cpj          <Plug>MagneditCopyLineDownHere      
    nmap cpk          <Plug>MagneditCopyLineUpHere        
    nmap cp]          <Plug>MagneditCopyParagraphDownHere     
    nmap cp[          <Plug>MagneditCopyParagraphUpHere   
                                                          
    nmap <leader>mvj  <Plug>MagneditMoveCurrentLineDown     
    nmap <leader>mvk  <Plug>MagneditMoveCurrentLineUp       
    nmap <leader>mv]  <Plug>MagneditMoveCurrentParagraphDown
    nmap <leader>mv[  <Plug>MagneditMoveCurrentParagraphUp              
                                                            
    nmap <leader>cpj  <Plug>MagneditCopyCurrentLineDown     
    nmap <leader>cpk  <Plug>MagneditCopyCurrentLineUp       
    nmap <leader>cp]  <Plug>MagneditCopyCurrentParagraphDown                                        
    nmap <leader>cp[  <Plug>MagneditCopyCurrentParagraphUp                                        
                                    
    vmap mvj          <Plug>MagneditMoveVisualDown    
    vmap mvk          <Plug>MagneditMoveVisualUp        
    vmap cpj          <Plug>MagneditCopyVisualDown      
    vmap cpk          <Plug>MagneditCopyVisualUp        
endif                                            

