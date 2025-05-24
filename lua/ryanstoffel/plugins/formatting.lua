-- Update your existing lua/ryanstoffel/plugins/formatting.lua
return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        cs = { "csharpier" },         -- C# formatter
        python = { "isort", "black" },
        java = { "google-java-format" },
        html = { "prettier" },
        css = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        sql = { "sql-formatter" },      -- MySQL (SQL) formatter
        -- Salesforce-specific formatters
        apex = { "apex-format" },       -- Custom Apex formatter (you may need to configure this)
        soql = { "sql-formatter" },     -- Use SQL formatter for SOQL
        xml = { "xmlformatter" },       -- For metadata files
        json = { "prettier" },          -- For JSON metadata
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
      -- Custom formatters for Salesforce
      formatters = {
        ["apex-format"] = {
          command = "sfdx",
          args = { "force:apex:format", "--file", "$FILENAME" },
          stdin = false,
          cwd = require("conform.util").root_file({ "sfdx-project.json" }),
        },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })

    -- Salesforce-specific formatting commands
    vim.keymap.set("n", "<leader>sff", function()
      if vim.bo.filetype == "apex" then
        vim.cmd("!sfdx force:apex:format " .. vim.fn.expand("%:p"))
        vim.cmd("edit!")  -- Reload the file to see changes
      else
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end
    end, { desc = "Format Salesforce file" })
  end,
}
