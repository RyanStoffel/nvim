-- nvim/lua/plugins/alpha.lua

return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VimEnter",
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		dashboard.section.buttons.val = {}
		dashboard.section.footer.val = {}
		require("alpha").setup(dashboard.config)
	end,
}
