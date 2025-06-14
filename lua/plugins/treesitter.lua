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
        -- Core languages
        "c", "cpp", "c_sharp", "java", "python",
        -- Salesforce
        "apex", "soql",
        -- Web development (NOTE: jsx is handled by javascript/typescript parsers)
        "javascript", "typescript", "tsx",  -- Removed "jsx"
        "html", "css", "json", "yaml", "xml", "sql",
        -- System & config
        "bash", "lua", "vim", "vimdoc",
        "regex", -- This should work now
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
