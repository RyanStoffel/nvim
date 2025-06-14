-- lua/rstof/salesforce-keymaps.lua
-- Salesforce-specific keymaps and utility functions

local M = {}

-- Utility functions for Salesforce development
M.salesforce_utils = {
  -- Function to check if we're in a Salesforce project
  is_salesforce_project = function()
    local handle = io.popen("find . -maxdepth 2 -name 'sfdx-project.json' 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
  end,

  -- Function to get current org info
  get_current_org = function()
    local handle = io.popen("sf org display --json 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    if result ~= "" then
      local success, json = pcall(vim.fn.json_decode, result)
      if success and json.result then
        return json.result.username or "Unknown"
      end
    end
    return "No org set"
  end,

  -- Function to run SOQL queries
  run_soql_query = function()
    vim.ui.input({ prompt = "Enter SOQL Query: " }, function(query)
      if query then
        local cmd = string.format("sf data query --query \"%s\" --json", query)
        vim.fn.system(cmd)
      end
    end)
  end,

  -- Function to create new Apex class
  create_apex_class = function()
    vim.ui.input({ prompt = "Apex Class Name: " }, function(name)
      if name then
        local cmd = string.format("sf apex generate class --name %s", name)
        vim.fn.system(cmd)
        vim.cmd("edit force-app/main/default/classes/" .. name .. ".cls")
      end
    end)
  end,

  -- Function to create new Apex trigger
  create_apex_trigger = function()
    vim.ui.input({ prompt = "Trigger Name: " }, function(name)
      if name then
        vim.ui.input({ prompt = "SObject: " }, function(sobject)
          if sobject then
            local cmd = string.format("sf apex generate trigger --name %s --sobject %s", name, sobject)
            vim.fn.system(cmd)
            vim.cmd("edit force-app/main/default/triggers/" .. name .. ".trigger")
          end
        end)
      end
    end)
  end,

  -- Function to create new Lightning Web Component
  create_lwc = function()
    vim.ui.input({ prompt = "LWC Name: " }, function(name)
      if name then
        local cmd = string.format("sf lightning generate component --name %s --type lwc", name)
        vim.fn.system(cmd)
        vim.cmd("edit force-app/main/default/lwc/" .. name .. "/" .. name .. ".js")
      end
    end)
  end,

  -- Function to open Salesforce documentation
  open_sf_docs = function()
    local word = vim.fn.expand("<cword>")
    if word ~= "" then
      local url = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_" .. string.lower(word) .. ".htm"
      vim.fn.system("open " .. url)
    else
      vim.fn.system("open https://developer.salesforce.com/docs/")
    end
  end,
}

-- Setup function to be called from init.lua
M.setup = function()
  local utils = M.salesforce_utils
  
  -- Only set up Salesforce keymaps if we're in a Salesforce project
  if utils.is_salesforce_project() then
    local keymap = vim.keymap
    local opts = { noremap = true, silent = true }

    -- Salesforce CLI commands
    keymap.set("n", "<leader>sdo", ":!sf org open<CR>", vim.tbl_extend("force", opts, { desc = "Open Salesforce Org" }))
    keymap.set("n", "<leader>sds", ":!sf project deploy start<CR>", vim.tbl_extend("force", opts, { desc = "Deploy to Org" }))
    keymap.set("n", "<leader>sdr", ":!sf project retrieve start<CR>", vim.tbl_extend("force", opts, { desc = "Retrieve from Org" }))
    keymap.set("n", "<leader>sdt", ":!sf apex run test<CR>", vim.tbl_extend("force", opts, { desc = "Run Apex Tests" }))
    keymap.set("n", "<leader>sdl", ":!sf org list<CR>", vim.tbl_extend("force", opts, { desc = "List Orgs" }))

    -- File creation commands
    keymap.set("n", "<leader>sac", function() utils.create_apex_class() end, vim.tbl_extend("force", opts, { desc = "Create Apex Class" }))
    keymap.set("n", "<leader>sat", function() utils.create_apex_trigger() end, vim.tbl_extend("force", opts, { desc = "Create Apex Trigger" }))
    keymap.set("n", "<leader>slc", function() utils.create_lwc() end, vim.tbl_extend("force", opts, { desc = "Create LWC" }))

    -- SOQL utilities
    keymap.set("n", "<leader>sqq", function() utils.run_soql_query() end, vim.tbl_extend("force", opts, { desc = "Run SOQL Query" }))
    keymap.set("n", "<leader>sqi", ":!sf org display<CR>", vim.tbl_extend("force", opts, { desc = "Show Org Info" }))

    -- Documentation
    keymap.set("n", "<leader>sdh", function() utils.open_sf_docs() end, vim.tbl_extend("force", opts, { desc = "Open SF Docs" }))

    -- Quick navigation for Salesforce project structure
    keymap.set("n", "<leader>sfc", ":e force-app/main/default/classes/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Classes" }))
    keymap.set("n", "<leader>sft", ":e force-app/main/default/triggers/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Triggers" }))
    keymap.set("n", "<leader>sfl", ":e force-app/main/default/lwc/<CR>", vim.tbl_extend("force", opts, { desc = "Go to LWC" }))
    keymap.set("n", "<leader>sfa", ":e force-app/main/default/aura/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Aura" }))
    keymap.set("n", "<leader>sfo", ":e force-app/main/default/objects/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Objects" }))
    keymap.set("n", "<leader>sfp", ":e force-app/main/default/permissionsets/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Permission Sets" }))

    -- Custom snippets for common Salesforce patterns
    keymap.set("n", "<leader>ssc", function()
      vim.api.nvim_put({
        "public class ClassName {",
        "    ",
        "    public ClassName() {",
        "        ",
        "    }",
        "    ",
        "}"
      }, "l", true, true)
    end, vim.tbl_extend("force", opts, { desc = "Insert Apex Class Template" }))

    keymap.set("n", "<leader>ssm", function()
      vim.api.nvim_put({
        "public static void methodName() {",
        "    ",
        "}"
      }, "l", true, true)
    end, vim.tbl_extend("force", opts, { desc = "Insert Apex Method Template" }))

    keymap.set("n", "<leader>sst", function()
      vim.api.nvim_put({
        "@isTest",
        "public class TestClassName {",
        "    ",
        "    @isTest",
        "    static void testMethod() {",
        "        // Test implementation",
        "        System.assert(true);",
        "    }",
        "    ",
        "}"
      }, "l", true, true)
    end, vim.tbl_extend("force", opts, { desc = "Insert Apex Test Class Template" }))

    -- Show current org in statusline
    vim.g.salesforce_org = utils.get_current_org()
    
    -- Autocommands for Salesforce development
    local salesforce_group = vim.api.nvim_create_augroup("SalesforceGroup", { clear = true })
    
    -- Auto-format Apex files on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = salesforce_group,
      pattern = "*.cls,*.trigger",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })

    -- Set specific indentation for Salesforce files
    vim.api.nvim_create_autocmd("FileType", {
      group = salesforce_group,
      pattern = "apex",
      callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
      end,
    })

    -- Set up XML formatting for metadata files
    vim.api.nvim_create_autocmd("FileType", {
      group = salesforce_group,
      pattern = "xml",
      callback = function()
        if vim.fn.expand("%:p"):match("force%-app") then
          vim.opt_local.tabstop = 4
          vim.opt_local.shiftwidth = 4
          vim.opt_local.expandtab = true
        end
      end,
    })

    print("Salesforce development environment loaded for: " .. vim.g.salesforce_org)
  end
end

return M
