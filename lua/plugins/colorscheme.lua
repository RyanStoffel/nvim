return {
  "catppuccin/nvim",
  name     = "catppuccin",
  lazy     = false,
  priority = 1000,
  config   = function()
    vim.cmd("colorscheme catppuccin")
    require("catppuccin").setup({
      integrations = { nvimtree = true, treesitter = true },
    })
  end,
}

