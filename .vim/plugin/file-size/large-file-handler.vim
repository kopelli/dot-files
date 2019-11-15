""""""""""""""""""""""""""""""""""""""""
" => Handling large files
""""""""""""""""""""""""""""""""""""""""
" file is larger than 50Mb
let s:LargeFileSize = 1024 * 1024 * 50
augroup LargeFile
    autocmd BufReadPre * let f=getfsize(expand("<afile>")) | if f > s:LargeFileSize || f == -2 | call PrepareForLargeFile() | endif
augroup END

if !exists("*PrepareForLargeFile")
    function PrepareForLargeFile()
        " no syntax highlighting
        set eventignore+=FileType

        " save memory when other file is viewed
        setlocal bufhidden=unload

        " no undo possible
        setlocal undolevels=-1

        " display message
        autocmd VimEnter *  echo "The file is larger than " . (s:LargeFileSize / 1024 / 1024) . " MB, so some options are changed (see ~/.vimrc for details)."
    endfunction
endif
