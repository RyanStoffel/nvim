-- lua/ryanstoffel/plugins/soql-builder.lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- Only set up SOQL tools if telescope is available
    local telescope_ok, telescope = pcall(require, "telescope")
    if not telescope_ok then
      vim.notify("Telescope not available for SOQL tools", vim.log.levels.WARN)
      return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- Check if we're in a Salesforce project
    local function is_salesforce_project()
      return vim.fn.filereadable("sfdx-project.json") == 1 or
             vim.fn.isdirectory("force-app") == 1 or
             vim.fn.isdirectory(".sfdx") == 1
    end

    -- Common Salesforce objects for quick selection
    local common_sobjects = {
      "Account", "Contact", "Lead", "Opportunity", "Case", "Task", "Event",
      "User", "Profile", "PermissionSet", "Organization", "UserRole",
      "Product2", "PricebookEntry", "Quote", "Contract", "Order",
      "Campaign", "CampaignMember", "Asset", "Solution", "Idea",
      "ContentDocument", "ContentVersion", "Attachment", "Note",
      "EmailMessage", "FeedItem", "Knowledge__kav", "Dashboard",
      "Report", "ListView", "CustomObject__c"
    }

    -- Common SOQL patterns
    local soql_patterns = {
      {
        name = "Basic Query",
        template = "SELECT Id, Name FROM Account WHERE Name != null LIMIT 100"
      },
      {
        name = "Count Query",
        template = "SELECT COUNT() FROM Account WHERE CreatedDate = TODAY"
      },
      {
        name = "With Parent Relationship",
        template = "SELECT Id, Name, Account.Name FROM Contact WHERE Account.Name != null"
      },
      {
        name = "With Child Relationship",
        template = "SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account"
      },
      {
        name = "Aggregate Query",
        template = "SELECT COUNT(Id), Type FROM Account GROUP BY Type"
      },
      {
        name = "Date Range Query",
        template = "SELECT Id, Name FROM Account WHERE CreatedDate >= LAST_MONTH"
      },
      {
        name = "Recent Records",
        template = "SELECT Id, Name FROM Account WHERE CreatedDate = LAST_N_DAYS:7 ORDER BY CreatedDate DESC"
      },
      {
        name = "Large Data Query",
        template = "SELECT Id, Name FROM Account ORDER BY CreatedDate DESC LIMIT 2000"
      }
    }

    -- SOQL Object Picker
    local function soql_object_picker()
      pickers.new({}, {
        prompt_title = "🔍 Select Salesforce Object",
        finder = finders.new_table {
          results = common_sobjects,
          entry_maker = function(entry)
            return {
              value = entry,
              display = "📋 " .. entry,
              ordinal = entry,
            }
          end,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            
            -- Insert the object name at cursor position
            local object_name = selection.value
            vim.api.nvim_put({object_name}, 'c', true, true)
            vim.notify("Inserted: " .. object_name, vim.log.levels.INFO)
          end)
          return true
        end,
      }):find()
    end

    -- SOQL Pattern Picker
    local function soql_pattern_picker()
      pickers.new({}, {
        prompt_title = "⚡ Choose SOQL Pattern",
        finder = finders.new_table {
          results = soql_patterns,
          entry_maker = function(entry)
            return {
              value = entry,
              display = "🔮 " .. entry.name,
              ordinal = entry.name,
            }
          end,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            
            -- Insert template
            local template = selection.value.template
            local lines = vim.split(template, '\n')
            vim.api.nvim_put(lines, 'l', true, true)
            vim.notify("Inserted SOQL pattern: " .. selection.value.name, vim.log.levels.INFO)
          end)
          return true
        end,
      }):find()
    end

    -- SOQL Query Executor
    local function execute_soql_query()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project", vim.log.levels.WARN)
        return
      end

      -- Get query text
      local query
      local mode = vim.fn.mode()
      
      if mode == 'v' or mode == 'V' or mode == '' then
        -- Get visually selected text
        vim.cmd('normal! "vy')
        query = vim.fn.getreg('v')
      else
        -- Get current line or ask for input
        local current_line = vim.fn.getline(".")
        if current_line:upper():match("SELECT") then
          query = current_line
        else
          query = vim.fn.input("SOQL Query: ")
        end
      end
      
      if query == "" then
        vim.notify("No query provided", vim.log.levels.WARN)
        return
      end
      
      -- Clean up the query
      query = query:gsub("%s+", " "):gsub("^%s*", ""):gsub("%s*$", "")
      
      -- Execute the query
      local cli_cmd = vim.fn.executable("sf") == 1 and "sf" or "sfdx"
      local cmd
      
      if cli_cmd == "sf" then
        cmd = "!sf data query --query \"" .. query .. "\" --result-format table"
      else
        cmd = "!sfdx force:data:soql:query -q \"" .. query .. "\" --resultformat table"
      end
      
      vim.notify("Executing SOQL query...", vim.log.levels.INFO)
      vim.cmd(cmd)
    end

    -- Schema Browser
    local function browse_schema()
      if not is_salesforce_project() then
        vim.notify("Not in a Salesforce project", vim.log.levels.WARN)
        return
      end

      vim.ui.input({ prompt = "Enter SObject API Name: " }, function(sobject)
        if sobject and sobject ~= "" then
          local cli_cmd = vim.fn.executable("sf") == 1 and "sf" or "sfdx"
          local cmd
          
          if cli_cmd == "sf" then
            cmd = "!sf sobject describe --sobject " .. sobject
          else
            cmd = "!sfdx force:schema:sobject:describe -s " .. sobject
          end
          
          vim.notify("Describing " .. sobject .. "...", vim.log.levels.INFO)
          vim.cmd(cmd)
        end
      end)
    end

    -- SOQL formatter function
    local function format_soql()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, " ")
      
      -- Basic SOQL formatting
      content = content:gsub("%s+", " ") -- Normalize whitespace
      content = content:gsub("^%s*", "") -- Remove leading whitespace
      content = content:gsub("%s*$", "") -- Remove trailing whitespace
      
      -- Format keywords on new lines
      content = content:gsub("(%s+)SELECT(%s+)", "\nSELECT ")
      content = content:gsub("(%s+)FROM(%s+)", "\nFROM ")
      content = content:gsub("(%s+)WHERE(%s+)", "\nWHERE ")
      content = content:gsub("(%s+)ORDER%s+BY(%s+)", "\nORDER BY ")
      content = content:gsub("(%s+)GROUP%s+BY(%s+)", "\nGROUP BY ")
      content = content:gsub("(%s+)HAVING(%s+)", "\nHAVING ")
      content = content:gsub("(%s+)LIMIT(%s+)", "\nLIMIT ")
      
      -- Split and clean lines
      local formatted_lines = {}
      for line in content:gmatch("[^\n]+") do
        local clean_line = line:match("^%s*(.-)%s*$") -- Trim whitespace
        if clean_line and clean_line ~= "" then
          table.insert(formatted_lines, clean_line)
        end
      end
      
      -- Replace buffer content
      if #formatted_lines > 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_lines)
        vim.notify("SOQL query formatted", vim.log.levels.INFO)
      end
    end

    -- Set up keymaps (only in Salesforce projects or for global access)
    vim.keymap.set("n", "<leader>sqo", soql_object_picker, { desc = "SOQL: Pick Object" })
    vim.keymap.set("n", "<leader>sqp", soql_pattern_picker, { desc = "SOQL: Pick Pattern" })
    vim.keymap.set("n", "<leader>sqe", execute_soql_query, { desc = "SOQL: Execute Query" })
    vim.keymap.set("v", "<leader>sqe", execute_soql_query, { desc = "SOQL: Execute Selected Query" })
    vim.keymap.set("n", "<leader>sqs", browse_schema, { desc = "SOQL: Browse Schema" })
    vim.keymap.set("n", "<leader>sqf", format_soql, { desc = "SOQL: Format Query" })

    -- Auto-commands for SOQL files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "soql",
      callback = function()
        -- SOQL-specific settings
        vim.opt_local.commentstring = "-- %s"
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        
        -- SOQL-specific keymaps (buffer local)
        vim.keymap.set("n", "<CR>", execute_soql_query, { buffer = true, desc = "Execute SOQL query" })
        vim.keymap.set("v", "<CR>", execute_soql_query, { buffer = true, desc = "Execute selected SOQL" })
        vim.keymap.set("n", "<leader>f", format_soql, { buffer = true, desc = "Format SOQL" })
      end,
    })

    -- Enhanced SOQL file detection
    vim.filetype.add({
      extension = {
        soql = "soql",
        sosl = "sosl",
      },
      pattern = {
        [".*%.soql"] = "soql",
        [".*%.sosl"] = "sosl",
      },
    })

    vim.notify("🔍 SOQL Power Tools loaded! Use <leader>sq* commands", vim.log.levels.INFO)
  end,
}
