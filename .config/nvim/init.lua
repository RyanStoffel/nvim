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

