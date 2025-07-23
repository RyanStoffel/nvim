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

-- behavior settings
vim.opt.hidden = true; -- allow hidden buffers
vim.opt.errorbells = false; -- no error bells
vim.opt.backspace = "indent,eol,start"; -- better backsapce behavior
vim.opt.autochdir = false; -- don't auto change directory
vim.opt.iskeyword:append("-"); -- treat dash as part of word
vim.opt.path:append("**"); -- include subdirectories in search
vim.opt.selection = "exclusive"; -- selection behavior
vim.opt.mouse = "a"; -- enable mouse support
vim.opt.clipboard:append("unnamedplus"); -- use system clipboard
vim.opt.modifiable = true; -- allow buffer modifications
vim.opt.encoding = "UTF-8"; -- set encoding

-- yank to end of line
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" });

-- set leader key
vim.g.mapleader = " ";
vim.g.maplocalleader = " ";

-- buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" });
vim.keymap.set("n", "<leader>bv", ":bprevious<CR>", { desc = "Previous buffer" });

-- splitting & resizing
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically"});
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally"});
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height"});
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height"});
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width"});  
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width"});  

-- better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" });
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" });
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" });
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" });

-- quick file navigation
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" });
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find file" });

-- quick config editing
vim.keymap.set("n", "<leader>rc", ":e ~/.dotfiles/nvim/.config/nvim/init.lua<CR>", { desc = "Edit config" });

-- copy full file path
vim.keymap.set("n", "<leader>pa", function()
  local path = vim.fn.expand("%:p");
  vim.fn.setreg("+", path);
  print("file:", path);
end);

-- basic auto commands
local augroup = vim.api.nvim_create_augroup("UserConfig", {});

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank();
  end,
});

-- return to the last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"');
    local lcount = vim.api.nvim_buf_line_count(0);
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark);
    end
  end,
});

-- auto close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {});
    end
  end,
});

-- auto resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =");
  end,
});

-- command line completion
vim.opt.wildmenu = true;
vim.opt.wildmode = "longest:full,full";
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" });

-- better diff options
vim.opt.diffopt:append("linematch:60");

-- performace improvements
vim.opt.redrawtime = 10000;
vim.opt.maxmempattern = 20000;

-- create undo dir if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir");
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p");
end;


-- floating terminal settings
local terminal_state = {
  buf = nil,
  win = nil,
  is_open = false
};

local function FloatingTerminal()
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false);
    terminal_state.is_open = false;
    return
  end

  -- create buffer if it doesn't exist or is invalid
  if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
    terminal_state.buf = vim.api.nvim_create_buf(false, true);
    -- set buffer options for better terminal experience
    vim.api.nvim_buf_set_option(terminal_state.buf, 'bufhidden', 'hide');
  end

  -- calcualte window dimensions
  local width  = math.floor(vim.o.columns * 0.8);
  local height = math.floor(vim.o.lines * 0.8);
  local row = math.floor((vim.o.lines - height) / 2);
  local col = math.floor((vim.o.columns - width) / 2);

  -- create floating window
  terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  });

  -- set transparency for the floating window
  vim.api.nvim_win_set_option(terminal_state.win, 'winblend', 0);

  -- set transparent background for the window
  vim.api.nvim_win_set_option(terminal_state.win, 'winhighlight', 'Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder');

  -- define highlight groups for transparency
  vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" });
  vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none", });

  -- start terminal if not already running
  local has_terminal = false;
  local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false);
  for _, line in ipairs(lines) do
    if line ~= "" then
      has_terminal = true;
      break
    end
  end

  if not has_terminal then
    vim.fn.termopen(os.getenv("SHELL"));
  end

  terminal_state.is_open = true;
  vim.cmd("startinsert");

  -- set up auto close on buffer leave
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = terminal_state.buf,
    callback = function()
      if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
        vim.api.nvim_win_close(terminal_state.win, false)
        terminal_state.is_open = false;
      end
    end,
    once = true;
  })
end

-- function to explicity close the terminal
local function CloseFloatingTerminal()
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false);
    terminal_state.is_open = false;
  end
end

-- key mappings
vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" });
vim.keymap.set("t", "<Esc>", function()
  if terminal_state.is_open then
    vim.api.nvim_win_close(terminal_state.win, false);
    terminal_state.is_open = false;
  end
end, { noremap = true, silent = true, desc = "Close floating terminal from terminal mode" });


-- git branch function
local function git_branch()
  local branch = vim.fn.system("git branch -- show-current 2>/dev/null | tr -d '\n'");
  if branch ~= "" then
    return "  " .. branch .. " ";
  end
  return "";
end
 -- file type with icon
 local function file_type()
   local ft = vim.bo.filetype;
   local icons = {
     lua = "[LUA]",
     python = "[PY]",
     javascript = "[JS]",
     html = "[HTML]",
     css = "[CSS]",
     json = "[JSON]",
     markdown = "[MD]",
     vim = "[VIM]",
     sh = "[SH]",
   }

   if ft == "" then
     return "  ";
   end

   return (icons[ft] or ft);
end

-- lsp status
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 });
  if #clients > 0 then
    return "  LSP ";
  end
  return "";
end

-- word count for text files
local function word_count()
  local ft = vim.bo.filetype;
  if ft == "markdown" or ft == "text" or ft == "tex" then
    local words = vim.fn.wordcount().words;
    return "  " .. words .. " words ";
  end
  return "";
end

-- file size
local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand('%'));
  if size < 0 then return "" end
  if size < 1024 then
    return size .. "B ";
  elseif size < 1024 * 1024 then
    return string.format("%.1fK", size / 1024);
  else
    return string.format("%.1fM", size / 1024 / 1024);
  end
end

-- mode indicators with icons
local function mode_icon()
  local mode = vim.fn.mode();
  local modes = {
    n = "NORMAL",
    i = "INSERT",
    c = "COMMAND",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK",
    R = "REPLACE",
    r = "REPLACE",
    ["!"] = "SHELL",
    t = "TERMINAL",
  }
  return modes[mode] or "  " .. mode:upper();
end

_G.mode_icon = mode_icon;
_G.git_branch = git_branch;
_G.file_type = file_type;
_G.file_size = file_size;
_G.lsp_status = lsp_status;

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]]);

-- function to change status line based on window focus
local function setup_dynamic_statusline()
  vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
    callback = function()
      vim.opt_local.statusline = table.concat {
        "  ",
        "%#StatusLineBold#",
        "%{v:lua.mode_icon()}",
        "%#StatusLine#",
        " | %f %h%m%r",
        "%{v:lua.git_branch()}",
        " | ",
        "%{v:lua.file_type()}",
        " | ",
        "%{v:lua.file_size()}",
        " | ",
        "%{v:lua.lsp_status()}",
        "%=",
        "%l:%c %P ",
      }
    end
  });
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true });

  vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
    callback = function()
      vim.opt_local.statusline = "  %f %h%m%r | %{v:lua.file_type()} | %= %l:%c  %P ";
    end
  });
end

setup_dynamic_statusline();
