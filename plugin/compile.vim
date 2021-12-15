if has('nvim-0.5')
        " command
        if exists('g:loaded_compile') | finish | endif " prevent loading file twice

        let s:save_cpo = &cpo " save user coptions
        set cpo&vim " reset them to defaults

        " command to run our plugin
        command! Compile lua require'compile'.compile()

        let &cpo = s:save_cpo " and restore after
        unlet s:save_cpo

        let g:loaded_compile = 1
else
        echo "You need neovim 0.5 or above to use this plugin!"
endif
