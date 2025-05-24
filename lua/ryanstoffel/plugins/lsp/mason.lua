-- Update your existing lua/ryanstoffel/plugins/lsp/mason.lua
return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- Safely import mason
    local mason_status, mason = pcall(require, "mason")
    if not mason_status then
      vim.notify("Failed to load mason.nvim", vim.log.levels.WARN)
      return
    end

    -- Safely import mason-lspconfig
    local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not mason_lspconfig_status then
      vim.notify("Failed to load mason-lspconfig.nvim", vim.log.levels.WARN)
      return
    end

    -- Safely import mason-tool-installer
    local mason_tool_installer_status, mason_tool_installer = pcall(require, "mason-tool-installer")
    if not mason_tool_installer_status then
      vim.notify("Failed to load mason-tool-installer.nvim", vim.log.levels.WARN)
      return
    end

    -- Enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- Import lspconfig and cmp_nvim_lsp here, as they are needed for handler configuration
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup({
      ensure_installed = {
        "clangd",         -- C, C++
        "omnisharp",      -- C# (Requires .NET SDK to be installed)
        "pyright",        -- Python
        "jdtls",          -- Java (Requires a JDK to be installed)
        "html",           -- HTML (Often provided by vscode-html-languageserver-bin)
        "cssls",          -- CSS (Often provided by vscode-css-languageserver-bin)
        "ts_ls",          -- TypeScript, JavaScript, React, Next.js (replaces deprecated tsserver)
        -- Salesforce LSP servers (Note: These may need manual installation)
        -- "apex_ls",        -- Apex Language Server (install manually via Salesforce CLI)
      },
      -- Configure handlers directly here
      handlers = {
        -- Custom handler for clangd
        ["clangd"] = function()
          lspconfig.clangd.setup({
            capabilities = capabilities,
            filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
            init_options = {
              fallbackFlags = { "-std=c++17" },
            },
          })
        end,
        
        -- Enhanced Java handler for Salesforce development
        ["jdtls"] = function()
          lspconfig.jdtls.setup({
            capabilities = capabilities,
            filetypes = { "java" },
            settings = {
              java = {
                configuration = {
                  updateBuildConfiguration = "interactive",
                },
                completion = {
                  favoriteStaticMembers = {
                    "org.junit.Assert.*",
                    "org.junit.Assume.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "org.junit.jupiter.api.Assumptions.*",
                    "org.junit.jupiter.api.DynamicContainer.*",
                    "org.junit.jupiter.api.DynamicTest.*",
                    "org.mockito.Mockito.*",
                    "org.mockito.ArgumentMatchers.*",
                    "org.mockito.Answers.*",
                    -- Salesforce specific imports
                    "System.*",
                    "Test.*",
                    "Database.*",
                  },
                },
                sources = {
                  organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                  },
                },
              },
            },
          })
        end,
        
        -- Default handler for all other servers
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
      },
      -- automatic_installation = true, -- Uncomment to enable automatic installation
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "clang-format",         -- C, C++ formatter
        "google-java-format",   -- Java formatter
        "prettier",             -- Formatter for HTML, CSS, JavaScript, TypeScript, React, Next.js
        "stylua",               -- Lua formatter
        "isort",                -- Python import sorter
        "black",                -- Python code formatter
        -- Salesforce development tools
        "xmlformatter",         -- XML formatter for metadata files
        "sql-formatter",        -- SQL formatter for SOQL queries
      },
    })
  end,
}
