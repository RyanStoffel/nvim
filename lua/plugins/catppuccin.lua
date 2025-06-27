return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- Load before all other plugins
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- Options: "latte", "frappe", "macchiato", "mocha"
      -- You can add more options here, see :h catppuccin or the README
    })
    vim.cmd.colorscheme "catppuccin"
  end,
}

