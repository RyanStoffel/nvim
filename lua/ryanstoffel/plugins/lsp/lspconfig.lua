return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    -- For added robustness, you can also wrap the require in pcall
    -- This pcall is still useful for general lspconfig setup, even if handlers move to mason.lua
    local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mason_lspconfig_ok then
      vim.notify("nvim-lspconfig: Failed to load mason-lspconfig.nvim. LSP setup might be incomplete.", vim.log.levels.ERROR)
    end

    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- ... (rest of your LspAttach and keymap setup, keep this part) ...
    local keymap = vim.keymap
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)
        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- Consider if :LspRestart is globally available or from a plugin
      end,
    })

    -- This line is no longer needed here if you move handler setup to mason.lua
    -- local capabilities = cmp_nvim_lsp.default_capabilities()

    -- --- START: Replaced deprecated sign_define with vim.diagnostic.config ---
    -- Old deprecated way:
    -- local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    -- for type, icon in pairs(signs) do
    --   local hl = "DiagnosticSign" .. type
    --   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    -- end

    -- New recommended way to configure diagnostic signs
    vim.diagnostic.config({
      virtual_text = true, -- Enable virtual text for diagnostics
      signs = {
        active = true, -- Enable signs for diagnostics
        -- Define the signs for each diagnostic severity
        text = {
          [vim.diagnostic.severity.ERROR] = " ", -- Error symbol
          [vim.diagnostic.severity.WARN]  = " ",  -- Warning symbol
          [vim.diagnostic.severity.INFO]  = " ",  -- Info symbol
          [vim.diagnostic.severity.HINT]  = "󰠠 ",  -- Hint symbol
        },
      },
      update_in_insert = false, -- Don't update diagnostics in insert mode
      float = {                 -- Configuration for the diagnostic floating window
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
    -- --- END: Replaced deprecated sign_define with vim.diagnostic.config ---

    -- --- START: Remove this block, as handlers are now configured in mason.lua ---
    -- if mason_lspconfig then
    --     mason_lspconfig.setup_handlers({
    --       ["clangd"] = function()
    --       lspconfig.clangd.setup({
    --         capabilities = capabilities,
    --         filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
    --         init_options = {
    --           fallbackFlags = { "-std=c++17" },
    --         },
    --       })
    --     end,
    --     function(server_name)
    --       lspconfig[server_name].setup({
    --         capabilities = capabilities,
    --       })
    --     end,
    --   })
    -- else
    --     vim.notify("mason-lspconfig not available, setting up LSPs manually or not at all.", vim.log.levels.WARN)
    -- end
    -- --- END: Remove this block ---

  end,
}
