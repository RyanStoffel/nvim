return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Helper function to check if we're in a Salesforce project
    local function is_salesforce_project()
      return vim.fn.filereadable("sfdx-project.json") == 1 or
             vim.fn.isdirectory("force-app") == 1 or
             vim.fn.isdirectory(".sfdx") == 1
    end

    -- Clean modern header
    dashboard.section.header.val = {
      "",
      "",
      "  ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
      "  ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
      "  ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
      "  ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
      "  ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
      "  ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
      "",
      is_salesforce_project() and "  Salesforce Development" or "  Code Editor",
      "",
      "",
    }

    -- Clean button configuration
    local buttons = {}

    -- Essential actions
    table.insert(buttons, dashboard.button("e", "  New file", "<cmd>ene<CR>"))
    table.insert(buttons, dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"))
    table.insert(buttons, dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"))
    table.insert(buttons, dashboard.button("w", "  Find text", "<cmd>Telescope live_grep<CR>"))

    -- Salesforce-specific actions (only if in Salesforce project)
    if is_salesforce_project() then
      table.insert(buttons, dashboard.button("", ""))
      table.insert(buttons, dashboard.button("a", "  Create Apex class", "<cmd>lua require('which-key').show('<leader>sca')<CR>"))
      table.insert(buttons, dashboard.button("l", "  Create Lightning component", "<cmd>lua require('which-key').show('<leader>scl')<CR>"))
      table.insert(buttons, dashboard.button("t", "  Create trigger", "<cmd>lua require('which-key').show('<leader>sct')<CR>"))
      table.insert(buttons, dashboard.button("", ""))
      table.insert(buttons, dashboard.button("o", "  Open org", "<cmd>lua vim.cmd(vim.fn.executable('sf') == 1 and '!sf org open' or '!sfdx force:org:open')<CR>"))
      table.insert(buttons, dashboard.button("d", "  Deploy", "<cmd>lua require('which-key').show('<leader>sf')<CR>"))
      table.insert(buttons, dashboard.button("s", "  Salesforce menu", "<cmd>lua require('which-key').show('<leader>s')<CR>"))
    end

    -- Project management
    table.insert(buttons, dashboard.button("", ""))
    table.insert(buttons, dashboard.button("p", "  Projects", "<cmd>Telescope find_files cwd=~<CR>"))
    table.insert(buttons, dashboard.button("c", "  Configuration", "<cmd>edit ~/.config/nvim/init.lua<CR>"))

    -- Session and quit
    table.insert(buttons, dashboard.button("", ""))
    table.insert(buttons, dashboard.button("z", "  Restore session", "<cmd>SessionRestore<CR>"))
    table.insert(buttons, dashboard.button("<C-q>", "  Quit", "<cmd>qa<CR>"))

    dashboard.section.buttons.val = buttons

    -- Clean footer
    local function get_footer()
      local stats = require("lazy").stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      
      local footer = {
        "",
        stats.loaded .. " plugins loaded in " .. ms .. "ms",
      }
      
      if is_salesforce_project() then
        table.insert(footer, "Press 's' for Salesforce commands")
      end
      
      return footer
    end

    dashboard.section.footer.val = get_footer()

    -- Clean color scheme
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- Minimal highlight groups
    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#c0caf5" })
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#565f89", italic = true })

    -- Salesforce accent colors
    if is_salesforce_project() then
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#00a1e0", bold = true })
      
      -- Apply Salesforce colors to specific buttons
      for i, button in ipairs(dashboard.section.buttons.val) do
        if button.val and (button.val:match("Apex") or button.val:match("Lightning") or button.val:match("trigger")) then
          button.opts = button.opts or {}
          button.opts.hl = "AlphaSalesforce"
        elseif button.val and (button.val:match("org") or button.val:match("Deploy") or button.val:match("Salesforce")) then
          button.opts = button.opts or {}
          button.opts.hl = "AlphaSalesforceAccent"
        end
      end
      
      vim.api.nvim_set_hl(0, "AlphaSalesforce", { fg = "#00a1e0" })
      vim.api.nvim_set_hl(0, "AlphaSalesforceAccent", { fg = "#ff6b35" })
    end

    alpha.setup(dashboard.opts)

    -- Auto-update footer
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        dashboard.section.footer.val = get_footer()
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
