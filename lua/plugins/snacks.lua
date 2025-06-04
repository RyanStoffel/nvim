return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = function()
    local function is_salesforce_project()
      return vim.fn.filereadable("sfdx-project.json") == 1 or vim.fn.isdirectory(".sfdx") == 1
    end

    -- Base sections with better spacing
    local sections = {
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
    }

    -- Add beautiful Salesforce section if in SF project
    if is_salesforce_project() then
      table.insert(sections, 3, {
        title = "⚡ Salesforce Lightning Development",
        padding = 2,
        indent = 1,
        {
          { key = "ac", action = ":SfCreateClass", desc = "🔨  Create Apex Class" },
          { key = "at", action = ":SfCreateTestClass", desc = "🧪  Create Test Class" },
          { key = "lc", action = ":SfCreateLWC", desc = "⚡  Create Lightning Web Component" },
          { key = "ds", action = ":SfDeploy", desc = "🚀  Deploy to Salesforce Org" },
          { key = "od", action = ":SfOpen", desc = "🌐  Open Salesforce Org" },
        }
      })
    end

    -- Add remaining sections with consistent styling
    table.insert(sections, {
      pane = 2,
      icon = " ",
      title = "Projects",
      section = "projects",
      indent = 2,
      padding = 1,
    })

    table.insert(sections, {
      pane = 2,
      section = "startup",
    })

    return {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        width = 70,
        sections = sections,
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
  end,
  keys = {
    { "<leader>ee", function() Snacks.explorer.open() end, desc = "Open File Explorer" },
  },
}
