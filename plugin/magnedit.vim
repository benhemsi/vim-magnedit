" Vim global plugin for long-range editing
" Last Change:	2020 Aug 8
" Maintainer:	Ben Hemsi <github.com/benhemsi>
" License:	This file is placed in the public domain
                                                   
if exists("g:loaded_magnedit")
  finish
endif
let g:loaded_magnedit = 1

function! s:EditCode(count,upOrDown,selection,editCommand)
    norm mz
    if a:upOrDown ==? "UP"
        let targetLine = s:GetTargetLine(line(".") - a:count)
        if a:selection ==? "LINE"
            let codeToEdit = targetLine
        elseif a:selection ==? "INNERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(targetLine,"inner")
        elseif a:selection ==? "OUTERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(targetLine,"outer")
        endif
    else
        let targetLine = s:GetTargetLine(line(".") + a:count)
        if a:selection ==? "LINE"
            let codeToEdit = targetLine
        elseif a:selection ==? "INNERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(targetLine,"inner")
        elseif a:selection ==? "OUTERPARAGRAPH"
            let codeToEdit = s:GetParagraphRange(targetLine,"outer")
        endif
    endif
    execute ":" . codeToEdit . a:editCommand
    norm `z
endfunction

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

nnoremap <silent> <Plug>MagneditDeleteLineDown             :<C-U>call <SID>EditCode(v:count,"down","line","d")<CR>
nnoremap <silent> <Plug>MagneditDeleteLineUp               :<C-U>call <SID>EditCode(v:count,"up","line","d")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphDown        :<C-U>call <SID>EditCode(v:count,"down","outerparagraph","d")<CR>
nnoremap <silent> <Plug>MagneditDeleteParagraphUp          :<C-U>call <SID>EditCode(v:count,"up","outerparagraph","d")<CR>
nnoremap <silent> <Plug>MagneditCopyLineDown               :<C-U>call <SID>EditCode(v:count,"down","line","y")<CR>
nnoremap <silent> <Plug>MagneditCopyLineUp                 :<C-U>call <SID>EditCode(v:count,"up","line","y")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphDown          :<C-U>call <SID>EditCode(v:count,"down","outerparagraph","y")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphUp            :<C-U>call <SID>EditCode(v:count,"up","outerparagraph","y")<CR>
nnoremap <silent> <Plug>MagneditInsertEmptyLineDown        :<C-U>call <SID>EditCode(v:count,"down","line","pu _")<CR>
nnoremap <silent> <Plug>MagneditInsertEmptyLineUp          :<C-U>call <SID>EditCode(v:count,"up","line","pu! _")<CR>
nnoremap <silent> <Plug>MagneditPasteDown                  :<C-U>call <SID>EditCode(v:count,"down","line","pu")<CR>
nnoremap <silent> <Plug>MagneditPasteUp                    :<C-U>call <SID>EditCode(v:count,"up","line","pu!")<CR>
nnoremap <silent> <Plug>MagneditCommentLineDown            :<C-U>call <SID>EditCodeWithNormalMode(v:count,"down","gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentLineUp              :<C-U>call <SID>EditCodeWithNormalMode(v:count,"up","gcc")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphDown       :<C-U>call <SID>EditCodeWithNormalMode(v:count,"down","gcap")<CR>
nnoremap <silent> <Plug>MagneditCommentParagraphUp         :<C-U>call <SID>EditCodeWithNormalMode(v:count,"up","gcap")<CR>
                                                                      
nnoremap <silent> <Plug>MagneditMoveLineDownHere           :<C-U>call <SID>EditCode(v:count,"down","line","m.")<CR>
nnoremap <silent> <Plug>MagneditMoveLineUpHere             :<C-U>call <SID>EditCode(v:count,"up","line","m.")<CR>
nnoremap <silent> <Plug>MagneditMoveParagraphDownHere      :<C-U>call <SID>EditCode(v:count,"down","outerparagraph","m.")<CR>
nnoremap <silent> <Plug>MagneditMoveParagraphUpHere        :<C-U>call <SID>EditCode(v:count,"up","outerparagraph","m.")<CR>
                                                                      
nnoremap <silent> <Plug>MagneditCopyLineDownHere           :<C-U>call <SID>EditCode(v:count,"down","line","co.")<CR>
nnoremap <silent> <Plug>MagneditCopyLineUpHere             :<C-U>call <SID>EditCode(v:count,"up","line","co.")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphDownHere      :<C-U>call <SID>EditCode(v:count,"down","outerparagraph","co.")<CR>
nnoremap <silent> <Plug>MagneditCopyParagraphUpHere        :<C-U>call <SID>EditCode(v:count,"up","outerparagraph","co.")<CR>
                                                                      
nnoremap <silent> <Plug>MagneditMoveCurrentLineDown        :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"down","line","m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentLineUp          :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"up","line","m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphDown   :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"down","outerparagraph","m")<CR>
nnoremap <silent> <Plug>MagneditMoveCurrentParagraphUp     :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"up","outerparagraph","m")<CR>
                                                                      
nnoremap <silent> <Plug>MagneditCopyCurrentLineDown        :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"down","line","co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentLineUp          :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"up","line","co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphDown   :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"down","outerparagraph","co")<CR>
nnoremap <silent> <Plug>MagneditCopyCurrentParagraphUp     :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"up","outerparagraph","co")<CR>
                                                                      
vnoremap <silent> <Plug>MagneditMoveVisualDown             :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"down","visual","m")<CR>
vnoremap <silent> <Plug>MagneditMoveVisualUp               :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"up","visual","m")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualDown             :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"down","visual","co")<CR>
vnoremap <silent> <Plug>MagneditCopyVisualUp               :<C-U>call <SID>EditCodeFromCurrentPosition(v:count,"up","visual","co")<CR>

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

    nmap mJ           <Plug>MagneditMoveLineDownHere       
    nmap mK           <Plug>MagneditMoveLineUpHere            
    nmap m]           <Plug>MagneditMoveParagraphDownHere  
    nmap m[           <Plug>MagneditMoveParagraphUpHere   
                                                 
    nmap cJ           <Plug>MagneditCopyLineDownHere      
    nmap cK           <Plug>MagneditCopyLineUpHere        
    nmap c]           <Plug>MagneditCopyParagraphDownHere     
    nmap c[           <Plug>MagneditCopyParagraphUpHere   

    nmap <leader>mJ   <Plug>MagneditMoveCurrentLineDown       
    nmap <leader>mK   <Plug>MagneditMoveCurrentLineUp       
    nmap <leader>m]   <Plug>MagneditMoveCurrentParagraphDown
    nmap <leader>m[   <Plug>MagneditMoveCurrentParagraphUp              
                                                            
    nmap <leader>cJ   <Plug>MagneditCopyCurrentLineDown     
    nmap <leader>cK   <Plug>MagneditCopyCurrentLineUp       
    nmap <leader>c]   <Plug>MagneditCopyCurrentParagraphDown                                        
    nmap <leader>c[   <Plug>MagneditCopyCurrentParagraphUp                                        
                                    
    vmap <leader>mJ   <Plug>MagneditMoveVisualDown    
    vmap <leader>mK   <Plug>MagneditMoveVisualUp        
    vmap <leader>cJ   <Plug>MagneditCopyVisualDown      
    vmap <leader>cK   <Plug>MagneditCopyVisualUp        
endif                                            

