-- nvim/lua/plugins/telescope.lua

return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
	cmd = "Telescope",
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				layout_strategy = "horizontal",
				sorting_strategy = "ascending",
				layout_config = { prompt_position = "top" },
				winblend = 10,
			},
		})
	end,
}
