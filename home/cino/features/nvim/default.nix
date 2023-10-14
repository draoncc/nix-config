{ pkgs, lib, ... }:

{
  imports = [ ./lsp.nix ./ui.nix ];

  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;

    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    extraConfig = # vim
      ''
        " Use system clipboard
        set clipboard=unnamedplus

        " Standard
        set tabstop=2      " Indendation of 2 spaces
        set expandtab      " Use spaces instead of real tab
        set softtabstop=0  " Use same length as 'tabstop'
        set shiftwidth=0   " Use same length as 'tabstop'
        set autowrite      " Auta-save before compiling
        set undofile       " Persistent undo files
        set undodir=$HOME/.config/nvim/undo
        set showcmd        " Show what is being typed
        set colorcolumn=80 " Highlight lines over 80 chars long
        set omnifunc=syntaxcomplete#Complete

        " Conceal markers
        if has('conceal')
          set conceallevel=0 concealcursor=niv
        endif

        " Fix nvim size according to terminal
        " https://github.com/neovim/neovim/issues/11330
        augroup fix_size
          autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()
        augroup END

        " Use ; as :
        map ; :
        noremap ;; ;

        " Copy paste
        nnoremap <Leader>p "+p
        nnoremap <Leader>y <S-v>"+y<CR>
        vnoremap <Leader>y "+y

        " Buffer movement
        nmap <C-s> :bnext<CR>
        nmap <C-h> :bprev<CR>
        nmap <C-q> :bdel<CR>
      '';

    extraPackages = with pkgs; [
      tree-sitter

      fzf

      # Extra language servers
      terraform-lsp
      nodePackages.typescript
      nodePackages.typescript-language-server
      gopls

      # Linters
      nodePackages.prettier
      nodePackages.eslint
    ];

    plugins = with pkgs.vimPlugins; [
      vimproc # Async execution library
      denops-vim # Deno engine for vim plugins
      vim-flake8 # Python syntax & style checker
      vim-polyglot # Syntax highlights

      clever-f-vim

      # Fuzzy file finder
      fzfWrapper
      {
        plugin = fzf-vim;
        type = "viml";
        config = # vim
          ''
            nmap <C-e> :FZF<CR>
          '';
      }

      # Linting engine
      {
        plugin = ale;
        type = "viml";
        config = # vim
          ''
            nmap <silent> <C-n> <Plug>(ale_previous_wrap)
            nmap <silent> <C-t> <Plug>(ale_previous_wrap)

            let g:ale_linters = {
            \   'javascript': ['eslint'],
            \   'typescript': ['eslint'],
            \   'dhall': ['dhall-lint'],
            \}

            let g:ale_fixers = {
            \   '*': ['remove_trailing_lines', 'trim_whitespace'],
            \   'python': ['black'],
            \   'nix': ['nixfmt'],
            \   'javascript': ['prettier', 'eslint'],
            \   'typescript': ['prettier', 'eslint'],
            \   'html': ['prettier'],
            \   'vue': ['prettier'],
            \   'dhall': ['dhall-format'],
            \   'sh': ['shfmt'],
            \}

            let g:ale_pattern_options = {
            \   '.*\.tf$': {
            \     'ale_linters': ['terraform'],
            \     'ale_fixers': ['terraform'],
            \   },
            \}

            let g:ale_fix_on_save = 1
            let g:ale_set_loclist = 0
            let g:ale_set_quickfix = 0
          '';
      }

      # Tree sitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = # lua
          ''
            require('nvim-treesitter.configs').setup{
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
            }
          '';
      }
    ];
  };
}
