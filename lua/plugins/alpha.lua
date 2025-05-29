return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    local function is_salesforce_project()
      return vim.fn.filereadable("sfdx-project.json") == 1 or vim.fn.isdirectory(".sfdx") == 1
    end

    if is_salesforce_project() then
      dashboard.section.header.val = {
        "                                                     ",
        "  ███████╗ █████╗ ██╗     ███████╗███████╗ ██████╗  ",
        "  ██╔════╝██╔══██╗██║     ██╔════╝██╔════╝██╔═══██╗ ",
        "  ███████╗███████║██║     █████╗  ███████╗██║   ██║ ",
        "  ╚════██║██╔══██║██║     ██╔══╝  ╚════██║██║   ██║ ",
        "  ███████║██║  ██║███████╗███████╗███████║╚██████╔╝ ",
        "  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ ╚═════╝  ",
        "                                                     ",
        "        ⚡ Lightning Fast Salesforce Development     ",
        "                                                     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("n", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("c", "  Config", "<cmd>e $MYVIMRC<CR>"),
        dashboard.button("", "", ""),
        dashboard.button("ac", "🔨 Create Apex Class", "<cmd>SfCreateClass<CR>"),
        dashboard.button("at", "🧪 Create Test Class", "<cmd>SfCreateTestClass<CR>"),
        dashboard.button("lc", "⚡ Create LWC", "<cmd>SfCreateLWC<CR>"),
        dashboard.button("", "", ""),
        dashboard.button("od", "🌐 Open Org", "<cmd>SfOpen<CR>"),
        dashboard.button("ds", "🚀 Deploy", "<cmd>SfDeploy<CR>"),
        dashboard.button("rt", "🔄 Retrieve", "<cmd>SfRetrieve<CR>"),
        dashboard.button("ts", "✅ Run Tests", "<cmd>SfTest<CR>"),
        dashboard.button("", "", ""),

      }

      local function get_org_info()
        local handle = io.popen("sf org display --json 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result ~= "" then
            local success, json = pcall(vim.fn.json_decode, result)
            if success and json and json.result then
              return json.result.username or "Unknown Org"
            end
          end
        end
        return "No Org Connected"
      end

      dashboard.section.footer.val = {
        "🏢 Current Org: " .. get_org_info(),
        "",
        os.date(" %d-%m-%Y   %H:%M:%S") .. "   " .. "v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
      }

    else
      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "                                                     ",
        "            🚀 Ready for Development                 ",
        "                                                     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("n", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("c", "  Config", "<cmd>e $MYVIMRC<CR>"),
        dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit NVIM", "<cmd>qa<CR>"),
      }

      dashboard.section.footer.val = os.date(" %d-%m-%Y   %H:%M:%S") .. "   " .. "v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
    end

    dashboard.section.footer.opts.hl = "Type"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

        if is_salesforce_project() then
          local current_footer = dashboard.section.footer.val
          dashboard.section.footer.val = {
            current_footer[1],
            "",
            "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms",
            current_footer[3]
          }
        else
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
        end

        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
