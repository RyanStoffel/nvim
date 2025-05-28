return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      ensure_installed = {
        "c", "cpp", "c_sharp", "java", "python",
        "apex", "soql",
        "javascript", "typescript", "tsx", "jsx",
        "html", "css", "json", "yaml", "xml", "sql",
        "bash", "lua", "vim", "vimdoc",
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<C-s>",
          node_decremental = "<M-space>",
        },
      },

      indent = {
        enable = true,
        disable = { "apex" },
      },
    })

    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    })
  end,
}
