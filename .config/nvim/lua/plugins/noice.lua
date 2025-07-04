return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim", "stevearc/dressing.nvim" },
  config = function()
    require("noice").setup()
  end,
}
