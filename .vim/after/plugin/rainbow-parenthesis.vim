if exists(":RainbowParenthesesToggleAll")
    " Rainbow Parentheses
    autocmd VimEnter * RainbowParenthesesToggleAll
    autocmd Syntax *   RainbowParenthesesLoadRound
    autocmd Syntax *   RainbowParenthesesLoadSquare
    autocmd Syntax *   RainbowParenthesesLoadBraces
    autocmd Syntax *   RainbowParenthesesLoadChevrons
endif
