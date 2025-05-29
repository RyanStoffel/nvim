return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = function()
    local function is_salesforce_project()
      return vim.fn.filereadable("sfdx-project.json") == 1 or vim.fn.isdirectory(".sfdx") == 1
    end

    local base_config = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        width = 60,
        row = nil,
        col = nil,
        pane_gap = 4,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          {
            pane = 2,
            icon = " ",
            title = "Recent Files",
            section = "recent_files",
            indent = 2,
            padding = 1,
          },
          {
            pane = 2,
            icon = " ",
            title = "Projects",
            section = "projects",
            indent = 2,
            padding = 1,
          },
          {
            pane = 2,
            section = "startup",
          },
        },
      },
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
    }

    -- If Salesforce project, modify the keys section
    if is_salesforce_project() then
      -- Insert Salesforce commands before Projects section
      table.insert(base_config.dashboard.sections, 4, {
        pane = 2,
        icon = "⚡",
        title = "Salesforce",
        section = "keys",
        indent = 2,
        padding = 1,
        keys = {
          { icon = "🔨", key = "ac", desc = "Create Apex Class", action = ":SfCreateClass" },
          { icon = "🧪", key = "at", desc = "Create Test Class", action = ":SfCreateTestClass" },
          { icon = "⚡", key = "lc", desc = "Create LWC", action = ":SfCreateLWC" },
          { icon = "🚀", key = "ds", desc = "Deploy", action = ":SfDeploy" },
          { icon = "🌐", key = "od", desc = "Open Org", action = ":SfOpen" },
        },
      })
    end

    return base_config
  end,
  keys = {
    { "<leader>ee", function() Snacks.explorer.open() end, desc = "Open File Explorer" },
  },
}
