-- colortheme & transparency settings
vim.cmd.colorscheme("default");
vim.api.nvim_set_hl(0, "Normal", { bg = "none" });
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" });
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" });

-- basic settings
vim.opt.number = true; -- line numbers
vim.opt.relativenumber = true; -- relative line numbers
vim.opt.cursorline = true; -- highlight the current line
vim.opt.wrap = false -- don't wrap lines
vim.opt.scrolloff = 10; -- keep 10 lines above/below the cursor
vim.opt.sidescrolloff = 8; -- keep 8 columns left/right of cursor

-- indentation settings
vim.opt.tabstop = 2; -- tab width
vim.opt.shiftwidth = 2; -- indent width
vim.opt.softtabstop = 2; -- soft tab stop
vim.opt.smartindent = true; -- smart auto indenting 
vim.opt.expandtab = true; -- use spaces instead of tabs 
vim.opt.autoindent = true; -- copy indent from current line

-- search settings
vim.opt.ignorecase = true; -- case insensitive search
vim.opt.smartcase = true; -- case sensitive if upper case in search
vim.opt.hlsearch = false; -- dont highlight results
vim.opt.incsearch = true; -- show matches as you type

-- visual settings
vim.opt.termguicolors = true; -- enable 24-bit colors
vim.opt.showmatch = true; -- highlight matching brackets
vim.opt.matchtime = 2; -- how long to highligh matching brackets
vim.opt.cmdheight = 1; -- command line height
vim.opt.completeopt = "menuone,noinsert,noselect"; -- completion options
vim.opt.showmode = false; -- dont show mode in command line
vim.opt.pumheight = 10; -- pop up menu height
vim.opt.pumblend = 10; -- pop up menu transparency
vim.opt.winblend = 0; -- floating window transparency
vim.opt.conceallevel = 0; -- don't hide markup
vim.opt.concealcursor = ""; -- don't hide cursor line markup
vim.opt.lazyredraw = true; -- don't redraw during macros
vim.opt.synmaxcol = 300; -- syntax highlighting limit

-- file handling settings
vim.opt.backup = false; -- don't create backup files
vim.opt.writebackup = false; -- don't create backup files before writing
vim.opt.swapfile = false; -- don't create swap files
vim.opt.undofile = true; -- persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir"); -- undo directory
vim.opt.updatetime = 300; -- faster completion
vim.opt.timeoutlen = 500; -- key timeout duration
vim.opt.ttimeoutlen = 0; -- key code timeout
vim.opt.autoread = true; -- auto reload files saved outside nvim
vim.opt.autowrite = false; -- don't auto save
