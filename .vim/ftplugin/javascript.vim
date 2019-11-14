" Automatically remove trailing whitespace from lines prior to saving the file
autocmd BufWritePre *.js :%s/\s\+$//e
