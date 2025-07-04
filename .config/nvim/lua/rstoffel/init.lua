-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.cursorline = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 300
vim.opt.timeoutlen = 400
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.pumheight = 10

-- Keymaps
vim.keymap.set({ "n", "x" }, "gy", '"+y')
vim.keymap.set({ "n", "x" }, "gp", '"+p')
