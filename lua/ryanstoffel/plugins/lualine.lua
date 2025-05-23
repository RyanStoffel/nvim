return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    local colors = {
      bg = "#282828",         -- gruvbox background
      fg = "#ebdbb2",         -- gruvbox foreground
      yellow = "#fabd2f",
      cyan = "#8ec07c",
      darkblue = "#458588",
      green = "#b8bb26",
      orange = "#fe8019",
      violet = "#d3869b",
      magenta = "#b16286",
      blue = "#83a598",
      red = "#fb4934",
      inactive_bg = "#3c3836",
      inactive_fg = "#a89984",
    }

    local gruvbox_theme = {
      normal = {
        a = { bg = colors.blue,   fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg,     fg = colors.fg },
        c = { bg = colors.bg,     fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green,  fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg,     fg = colors.fg },
        c = { bg = colors.bg,     fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg,     fg = colors.fg },
        c = { bg = colors.bg,     fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg,     fg = colors.fg },
        c = { bg = colors.bg,     fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red,    fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg,     fg = colors.fg },
        c = { bg = colors.bg,     fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.inactive_fg, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.inactive_fg },
        c = { bg = colors.inactive_bg, fg = colors.inactive_fg },
      },
    }

    lualine.setup({
      options = {
        theme = gruvbox_theme,
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = colors.orange },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
  end,
}

