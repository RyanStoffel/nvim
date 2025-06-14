return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason-lspconfig.nvim",
    { "folke/neodev.nvim", opts = {} },
    { "antosha417/nvim-lsp-file-operations", config = true }
  },
  config = function()
    require("neodev").setup()
    local lspconfig        = require("lspconfig")
    local mason_lspconfig  = require("mason-lspconfig")
    local cmp_nvim_lsp     = require("cmp_nvim_lsp")
    local util             = require("lspconfig.util")
    local capabilities     = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup({
      ensure_installed = {
        -- Your existing working servers
        "clangd","jdtls","pyright","omnisharp","sqlls",
        "html","cssls","tailwindcss","lua_ls","ts_ls",
        -- Corrected server names for Salesforce support
        "jsonls",    -- JSON Language Server (correct name)
        "lemminx",   -- XML Language Server (correct name)
        "yamlls",    -- YAML Language Server (correct name)
        -- NOTE: There's no official Apex LS in Mason yet, we'll handle this separately
      },
      automatic_installation = true,
      handlers = {
        function(server_name)
          lspconfig[server_name].setup({ capabilities = capabilities })
        end,

        -- Enhanced Lua configuration
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime     = { version = "LuaJIT", path = vim.split(package.path, ";") },
                diagnostics = { globals = { "vim" } },
                workspace   = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
                telemetry   = { enable = false }
              }
            }
          })
        end,

        -- TypeScript/JavaScript configuration
        ["ts_ls"] = function()
          lspconfig.ts_ls.setup({
            capabilities = capabilities,
            on_attach = function(client)
              client.server_capabilities.documentFormattingProvider = false
            end,
            root_dir = util.root_pattern("next.config.js","package.json","tsconfig.json","jsconfig.json",".git"),
            filetypes = {
              "javascript","javascriptreact","javascript.jsx",
              "typescript","typescriptreact","typescript.tsx"
            }
          })
        end,

        -- JSON Language Server for Salesforce config files
        ["jsonls"] = function()
          lspconfig.jsonls.setup({
            capabilities = capabilities,
            filetypes = { "json", "jsonc" },
            settings = {
              json = {
                schemas = {
                  {
                    fileMatch = { "sfdx-project.json" },
                    url = "https://raw.githubusercontent.com/forcedotcom/cli/main/schemas/sfdx-project.schema.json"
                  },
                  {
                    fileMatch = { "scratch-def.json" },
                    url = "https://raw.githubusercontent.com/forcedotcom/cli/main/schemas/scratch-org-def.schema.json"
                  }
                },
                validate = { enable = true },
                format = { enable = true }
              }
            }
          })
        end,

        -- XML Language Server for Salesforce metadata
        ["lemminx"] = function()
          lspconfig.lemminx.setup({
            capabilities = capabilities,
            filetypes = { "xml" },
            root_dir = util.root_pattern("sfdx-project.json", ".sfdx", ".git", "pom.xml"),
            settings = {
              xml = {
                validation = { enabled = true },
                completion = { autoCloseTags = true },
                format = { enabled = true },
              }
            }
          })
        end,

        -- YAML Language Server
        ["yamlls"] = function()
          lspconfig.yamlls.setup({
            capabilities = capabilities,
            filetypes = { "yaml", "yml" },
            settings = {
              yaml = {
                format = { enable = true },
                validate = true,
                completion = true,
              }
            }
          })
        end,
      }
    })

    -- Manual Apex language support (since no official LSP in Mason yet)
    -- This provides basic syntax highlighting and some IntelliSense
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "apex",
      callback = function()
        -- Set up basic Apex file handling
        vim.opt_local.commentstring = "// %s"
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true

        -- Add some basic Apex keywords for highlighting
        vim.cmd([[
          syntax keyword apexKeyword global public private protected static abstract virtual override
          syntax keyword apexKeyword class interface extends implements
          syntax keyword apexKeyword if else for while do switch case default break continue return
          syntax keyword apexKeyword try catch finally throw
          syntax keyword apexKeyword new this super
          syntax keyword apexType Boolean Integer Long Double Decimal String Date Datetime Time
          syntax keyword apexType List Set Map SObject Database System
          syntax keyword apexAnnotation @isTest @future @RemoteAction @HttpGet @HttpPost @AuraEnabled

          highlight link apexKeyword Keyword
          highlight link apexType Type
          highlight link apexAnnotation PreProc
        ]])
      end,
    })

    -- Enhanced diagnostic signs
    for type, icon in pairs({
      Error=" ",
      Warn=" ",
      Hint="󰠠 ",
      Info=" "
    }) do
      vim.fn.sign_define("DiagnosticSign"..type, {
        text=icon,
        texthl="DiagnosticSign"..type,
        numhl=""
      })
    end

    -- LSP attach autocmd
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local km   = vim.keymap
        local opts = { buffer = ev.buf, silent = true }

        -- Navigation
        km.set("n","gR","<cmd>Telescope lsp_references<CR>", vim.tbl_extend("force", opts, { desc = "LSP References" }))
        km.set("n","gD",vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
        km.set("n","gd","<cmd>Telescope lsp_definitions<CR>", vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
        km.set("n","gi","<cmd>Telescope lsp_implementations<CR>", vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
        km.set("n","gt","<cmd>Telescope lsp_type_definitions<CR>", vim.tbl_extend("force", opts, { desc = "Go to Type Definition" }))

        -- Actions
        km.set({ "n","v" },"<leader>ca",vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Actions" }))
        km.set("n","<leader>rn",vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))

        -- Diagnostics
        km.set("n","<leader>D","<cmd>Telescope diagnostics bufnr=0<CR>", vim.tbl_extend("force", opts, { desc = "Buffer Diagnostics" }))
        km.set("n","<leader>d",vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show Diagnostic" }))
        km.set("n","[d",vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" }))
        km.set("n","]d",vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))

        -- Information
        km.set("n","K",vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
        km.set("n","<C-k>",vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature Help" }))

        -- Formatting
        km.set("n","<leader>f",function() vim.lsp.buf.format { async = true } end, vim.tbl_extend("force", opts, { desc = "Format Document" }))

        -- LSP Control
        km.set("n","<leader>rs",":LspRestart<CR>", vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
      end
    })

    -- Enhanced diagnostic configuration
    vim.diagnostic.config({
      virtual_text = {
        prefix = "●",
        source = "always",
      },
      float = {
        source = "always",
        border = "rounded",
      },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end
}
