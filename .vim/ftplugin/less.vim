" Automatically remove trailing whitespace from lines prior to saving the file
autocmd BufWritePre *.less :%s/\s\+$//e
