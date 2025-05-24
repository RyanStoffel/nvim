return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    treesitter.setup({ 
      -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      -- ensure these language parsers are installed (added Salesforce languages)
      ensure_installed = {
        "json",
        "java",
        "python",
        "cpp",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "c",
        -- Salesforce-specific parsers
        "apex",         -- Apex language
        "soql",         -- SOQL queries
        "sosl",         -- SOSL searches
        "xml",          -- For Lightning components and metadata
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })

    -- Set up file type associations for Salesforce files
    vim.filetype.add({
      extension = {
        cls = "apex",           -- Apex classes
        trigger = "apex",       -- Apex triggers
        page = "html",          -- Visualforce pages
        component = "html",     -- Visualforce components
        soql = "soql",          -- SOQL files
        sosl = "sosl",          -- SOSL files
        xml = "xml",            -- Metadata files
        js = "javascript",      -- Lightning Web Component JS
        html = "html",          -- Lightning Web Component HTML
        css = "css",            -- Lightning Web Component CSS
      },
      pattern = {
        [".*%.apex"] = "apex",
        [".*%.cls"] = "apex",
        [".*%.trigger"] = "apex",
        [".*%.soql"] = "soql",
        [".*%.sosl"] = "sosl",
      },
    })
  end,
}
