-- lua/ryanstoffel/plugins/lsp/salesforce.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    
    -- Enhanced capabilities for Salesforce development
    local capabilities = cmp_nvim_lsp.default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- Check for Apex Language Server
    local apex_lsp_path = vim.fn.expand("$HOME/.local/share/apex-ls/apex-lsp")
    local java_cmd = "java"
    local apex_jar = vim.fn.expand("$HOME/.local/share/apex-ls/apex-jorje-lsp.jar")

    -- Get Java home safely
    local java_home = vim.env.JAVA_HOME or "/usr/lib/jvm/default-java"
    if vim.env.JAVA_HOME then
      java_cmd = vim.env.JAVA_HOME .. "/bin/java"
    end

    -- Create custom Apex Language Server configuration
    local configs = require("lspconfig.configs")
    if not configs.apex_ls then
      configs.apex_ls = {
        default_config = {
          cmd = { apex_lsp_path },
          filetypes = { "apex" },
          root_dir = lspconfig.util.root_pattern("sfdx-project.json", ".forceignore", ".git"),
          single_file_support = true,
          settings = {
            apex = {
              enable = true,
              javaHome = java_home,
              enableSemanticErrors = true,
              enableCompletionStatistics = false,
            }
          },
        },
      }
    end

    -- Setup Apex Language Server if available
    if vim.fn.executable(apex_lsp_path) == 1 or vim.fn.filereadable(apex_jar) == 1 then
      lspconfig.apex_ls.setup({
        capabilities = capabilities,
        cmd = vim.fn.executable(apex_lsp_path) == 1 and { apex_lsp_path } or 
              { java_cmd, "-cp", apex_jar, "apex.jorje.lsp.ApexLanguageServerLauncher" },
        on_attach = function(client, bufnr)
          -- Salesforce-specific keymaps
          local opts = { buffer = bufnr, silent = true }
          
          -- Standard LSP keymaps
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          
          -- Salesforce-specific commands
          vim.keymap.set("n", "<leader>sf", function()
            local cli_cmd = vim.fn.executable("sf") == 1 and "sf" or "sfdx"
            local deploy_cmd = cli_cmd == "sf" and 
              ("!sf project deploy start --source-dir " .. vim.fn.expand("%:p")) or
              ("!sfdx force:source:deploy -p " .. vim.fn.expand("%:p"))
            vim.cmd(deploy_cmd)
          end, { desc = "Deploy current file to Salesforce", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>sr", function()
            local cli_cmd = vim.fn.executable("sf") == 1 and "sf" or "sfdx"
            local retrieve_cmd = cli_cmd == "sf" and 
              ("!sf project retrieve start --source-dir " .. vim.fn.expand("%:p")) or
              ("!sfdx force:source:retrieve -p " .. vim.fn.expand("%:p"))
            vim.cmd(retrieve_cmd)
          end, { desc = "Retrieve current file from Salesforce", buffer = bufnr })
        end,
      })
      vim.notify("Apex Language Server configured successfully", vim.log.levels.INFO)
    else
      vim.notify("Apex Language Server not found at " .. apex_lsp_path .. " or " .. apex_jar, vim.log.levels.WARN)
    end

    -- Basic language server for SOQL files (simple syntax highlighting)
    -- Only setup sqlls if it's available
    if vim.fn.executable("sql-language-server") == 1 then
      lspconfig.sqlls.setup({
        capabilities = capabilities,
        filetypes = { "sql", "soql" },
        root_dir = lspconfig.util.root_pattern("sfdx-project.json", ".forceignore", ".git"),
      })
    end

    -- Set up file type associations
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = {"*.cls", "*.trigger"},
      callback = function()
        vim.bo.filetype = "apex"
      end
    })

    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = "*.soql",
      callback = function()
        vim.bo.filetype = "soql"
      end
    })

    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = "*.sosl", 
      callback = function()
        vim.bo.filetype = "sosl"
      end
    })
  end,
}
