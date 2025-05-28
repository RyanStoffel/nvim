local opt = vim.opt

-- LINE OPTIONS --
opt.relativenumber = true
opt.number = true
opt.wrap = false

-- CURSOR OPTIONS
opt.cursorline = true

-- TABS & INDENTS --
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.autoindent = true
opt.cindent = true
opt.smarttab = true

-- CLIPBOARD --
opt.clipboard = "unnamedplus"

-- FILE BUFFER --
opt.confirm = true

-- SEARCH OPTIONS
opt.ignorecase = true
opt.smartcase = true

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
