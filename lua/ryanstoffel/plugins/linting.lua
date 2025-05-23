return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      c = { "clangtidy" },        -- C linting (requires clangtidy installed)
      cpp = { "clangtidy" },       -- C++ linting
      python = { "pylint" },       -- Python linting
      html = { "htmlhint" },       -- HTML linting
      css = { "stylelint" },       -- CSS linting
      javascript = { "eslint" }, -- JavaScript linting
      javascriptreact = { "eslint" }, -- React/JSX linting
      typescript = { "eslint" }, -- TypeScript linting
      typescriptreact = { "eslint" }, -- TSX linting
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}

