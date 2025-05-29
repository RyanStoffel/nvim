return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
		explorer = { enabled = true },
  },
	config = function()
		local keymap = vim.keymap
		keymap.set("n", "<leader>ee", "<cmd>lua Snacks.explorer.open()<CR>", { desc = "Open File Explorer" })
	end,
}
