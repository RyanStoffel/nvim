-- lua/ryanstoffel/plugins/org-switcher.lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local telescope_ok, telescope = pcall(require, "telescope")
    if not telescope_ok then
      vim.notify("Telescope not available for org switcher", vim.log.levels.WARN)
      return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    -- Check if we're in a Salesforce project
    local function is_salesforce_project()
      return vim.fn.filereadable("sfdx-project.json") == 1 or
             vim.fn.isdirectory("force-app") == 1 or
             vim.fn.isdirectory(".sfdx") == 1
    end

    -- Get CLI command (sf or sfdx)
    local function get_cli_cmd()
      return vim.fn.executable("sf") == 1 and "sf" or "sfdx"
    end

    -- Parse org list from CLI output
    local function parse_org_list(output)
      local orgs = {}
      local success, data = pcall(vim.json.decode, output)
      
      if not success or not data or not data.result then
        return orgs
      end

      -- Handle both sf and sfdx output formats
      local org_list = data.result
      if data.result.nonScratchOrgs then
        -- sfdx format
        for _, org in ipairs(data.result.nonScratchOrgs or {}) do
          table.insert(orgs, org)
        end
        for _, org in ipairs(data.result.scratchOrgs or {}) do
          table.insert(orgs, org)
        end
      else
        -- sf format or direct list
        if type(org_list) == "table" then
          for _, org in ipairs(org_list) do
            table.insert(orgs, org)
          end
        end
      end

      return orgs
    end

    -- Get list of available orgs
    local function get_orgs()
      local cli_cmd = get_cli_cmd()
      local cmd = cli_cmd == "sf" and "sf org list --json" or "sfdx force:org:list --json"
      
      local handle = io.popen(cmd .. " 2>/dev/null")
      if not handle then
        vim.notify("Failed to get org list", vim.log.levels.ERROR)
        return {}
      end
      
      local output = handle:read("*a")
      handle:close()
      
      if not output or output == "" then
        vim.notify("No orgs found or CLI error", vim.log.levels.WARN)
        return {}
      end
      
      return parse_org_list(output)
    end

    -- Get current default org
    local function get_current_org()
      local cli_cmd = get_cli_cmd()
      local cmd = cli_cmd == "sf" and "sf config get target-org --json" or "sfdx config:get defaultusername --json"
      
      local handle = io.popen(cmd .. " 2>/dev/null")
      if not handle then
        return nil
      end
      
      local output = handle:read("*a")
      handle:close()
      
      if not output or output == "" then
        return nil
      end
      
      local success, data = pcall(vim.json.decode, output)
      if success and data and data.result then
        if cli_cmd == "sf" then
          return data.result[1] and data.result[1].value
        else
          return data.result.defaultusername
        end
      end
      
      return nil
    end

    -- Set default org
    local function set_default_org(org_alias)
      local cli_cmd = get_cli_cmd()
      local cmd
      
      if cli_cmd == "sf" then
        cmd = "sf config set target-org " .. org_alias
      else
        cmd = "sfdx config:set defaultusername=" .. org_alias
      end
      
      local result = vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        vim.notify("✅ Set default org to: " .. org_alias, vim.log.levels.INFO)
        -- Refresh lualine to show new org
        pcall(require("lualine").refresh)
      else
        vim.notify("❌ Failed to set default org: " .. result, vim.log.levels.ERROR)
      end
    end

    -- Format org display
    local function format_org_display(org)
      local current_org = get_current_org()
      local is_current = (org.alias == current_org) or (org.username == current_org)
      local current_indicator = is_current and "👑 " or "   "
      
      local org_type_icon = ""
      if org.isExpired then
        org_type_icon = "💀"
      elseif org.isScratchOrg then
        org_type_icon = "🧪"
      elseif org.isDevHub then
        org_type_icon = "🏠"
      elseif org.connectedStatus == "Connected" then
        org_type_icon = "🟢"
      else
        org_type_icon = "🔴"
      end
      
      local alias = org.alias or "No Alias"
      local username = org.username or "Unknown"
      local org_type = org.isScratchOrg and "Scratch" or (org.isDevHub and "DevHub" or "Prod/Sandbox")
      
      return string.format("%s%s %s (%s) - %s", current_indicator, org_type_icon, alias, username, org_type)
    end

    -- Get org details for preview
    local function get_org_details(org)
      local details = {
        "🏢 Organization Details",
        "========================",
        "",
        "📝 Alias: " .. (org.alias or "None"),
        "👤 Username: " .. (org.username or "Unknown"),
        "🆔 Org ID: " .. (org.orgId or "Unknown"),
        "🌐 Instance: " .. (org.instanceUrl or "Unknown"),
        "",
        "📊 Status Information",
        "====================",
        "",
        "🔗 Connected: " .. (org.connectedStatus or "Unknown"),
        "🧪 Scratch Org: " .. (org.isScratchOrg and "Yes" or "No"),
        "🏠 Dev Hub: " .. (org.isDevHub and "Yes" or "No"),
        "⏰ Expired: " .. (org.isExpired and "Yes" or "No"),
      }
      
      if org.expirationDate then
        table.insert(details, "📅 Expires: " .. org.expirationDate)
      end
      
      if org.createdDate then
        table.insert(details, "📅 Created: " .. org.createdDate)
      end
      
      if org.edition then
        table.insert(details, "📦 Edition: " .. org.edition)
      end
      
      return details
    end

    -- Org switcher picker
    local function org_switcher()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project", vim.log.levels.WARN)
        return
      end

      vim.notify("Loading orgs...", vim.log.levels.INFO)
      local orgs = get_orgs()
      
      if #orgs == 0 then
        vim.notify("No orgs found. Try 'sf org login web' first", vim.log.levels.WARN)
        return
      end

      pickers.new({}, {
        prompt_title = "🌐 Switch Salesforce Org",
        finder = finders.new_table {
          results = orgs,
          entry_maker = function(org)
            return {
              value = org,
              display = format_org_display(org),
              ordinal = (org.alias or "") .. " " .. (org.username or "") .. " " .. (org.orgId or ""),
            }
          end,
        },
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
          title = "Org Details",
          define_preview = function(self, entry, status)
            local details = get_org_details(entry.value)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, details)
            vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
          end,
        }),
        attach_mappings = function(prompt_bufnr, map)
          -- Set as default org
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            
            local org = selection.value
            local org_identifier = org.alias or org.username
            
            if org_identifier then
              set_default_org(org_identifier)
            else
              vim.notify("❌ Cannot identify org", vim.log.levels.ERROR)
            end
          end)
          
          -- Open org in browser
          map("i", "<C-o>", function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            
            local org = selection.value
            local org_identifier = org.alias or org.username
            
            if org_identifier then
              local cli_cmd = get_cli_cmd()
              local cmd = cli_cmd == "sf" and 
                ("sf org open --target-org " .. org_identifier) or
                ("sfdx force:org:open -u " .. org_identifier)
              
              vim.notify("🌐 Opening " .. org_identifier .. " in browser...", vim.log.levels.INFO)
              vim.fn.system(cmd)
            end
          end)
          
          -- Delete/logout org
          map("i", "<C-d>", function()
            local selection = action_state.get_selected_entry()
            local org = selection.value
            local org_identifier = org.alias or org.username
            
            if not org_identifier then
              vim.notify("❌ Cannot identify org", vim.log.levels.ERROR)
              return
            end
            
            local confirm = vim.fn.input("Delete/logout org '" .. org_identifier .. "'? (y/N): ")
            if confirm:lower() == "y" then
              actions.close(prompt_bufnr)
              
              local cli_cmd = get_cli_cmd()
              local cmd
              
              if org.isScratchOrg then
                cmd = cli_cmd == "sf" and 
                  ("sf org delete scratch --target-org " .. org_identifier) or
                  ("sfdx force:org:delete -u " .. org_identifier)
              else
                cmd = cli_cmd == "sf" and 
                  ("sf org logout --target-org " .. org_identifier) or
                  ("sfdx auth:logout -u " .. org_identifier)
              end
              
              vim.notify("🗑️  Removing " .. org_identifier .. "...", vim.log.levels.INFO)
              local result = vim.fn.system(cmd)
              
              if vim.v.shell_error == 0 then
                vim.notify("✅ Removed org: " .. org_identifier, vim.log.levels.INFO)
              else
                vim.notify("❌ Failed to remove org: " .. result, vim.log.levels.ERROR)
              end
            end
          end)
          
          return true
        end,
      }):find()
    end

    -- Quick org info display
    local function show_current_org_info()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project", vim.log.levels.WARN)
        return
      end

      local cli_cmd = get_cli_cmd()
      local cmd = cli_cmd == "sf" and "sf org display --json" or "sfdx force:org:display --json"
      
      local handle = io.popen(cmd .. " 2>/dev/null")
      if not handle then
        vim.notify("Failed to get org info", vim.log.levels.ERROR)
        return
      end
      
      local output = handle:read("*a")
      handle:close()
      
      if not output or output == "" then
        vim.notify("No current org set", vim.log.levels.WARN)
        return
      end
      
      local success, data = pcall(vim.json.decode, output)
      if success and data and data.result then
        local org = data.result
        local info = {
          "🏢 Current Org: " .. (org.alias or org.username or "Unknown"),
          "🆔 Org ID: " .. (org.id or "Unknown"),
          "🌐 Instance: " .. (org.instanceUrl or "Unknown"),
          "👤 Username: " .. (org.username or "Unknown"),
          "📦 Edition: " .. (org.orgName or "Unknown"),
        }
        
        vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
      else
        vim.notify("Failed to parse org info", vim.log.levels.ERROR)
      end
    end

    -- Set up keymaps - using different keys to avoid conflicts
    vim.keymap.set("n", "<leader>sos", org_switcher, { desc = "Switch Salesforce Org" })
    vim.keymap.set("n", "<leader>soi", show_current_org_info, { desc = "Show Current Org Info" })
    
    -- Alternative keymaps
    vim.keymap.set("n", "<leader>so", org_switcher, { desc = "Org Switcher" })
    vim.keymap.set("n", "<leader>sO", org_switcher, { desc = "Org Switcher (Alt)" })

    vim.notify("🌐 Org Switcher loaded! Use <leader>soo to switch orgs", vim.log.levels.INFO)
  end,
}
