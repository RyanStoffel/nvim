return
{
	"elihunter173/dirbuf.nvim",
	config = function()
		local dirbuf = require("dirbuf")
		dirbuf.setup({})

		local keymap = vim.keymap
		keymap.set("n", "<leader>db", "<cmd>Dirbuf<CR>", { desc = "Toggle Dirbuf File Explorer" })
		keymap.set("n", "<leader>dq", "<cmd>DirbufQuit<CR>", { desc = "Quit Dirbuf File Explorer" })
	end,
}
