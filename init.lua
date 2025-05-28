-- Updated init.lua with Salesforce development enhancements
require("rstof.lazy")
require("rstof.options")

-- Load Salesforce-specific configurations
local salesforce_ok, salesforce = pcall(require, "rstof.salesforce-keymaps")
if salesforce_ok then
  salesforce.setup()
end

-- Enhanced options for Salesforce development
local opt = vim.opt

-- Better search and replace for large codebases
opt.grepprg = "rg --vimgrep --smart-case --follow"

-- Enhanced completion settings
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 15 -- Limit popup menu height

-- Better diff settings for Git integration
opt.diffopt = "internal,filler,closeoff,hiddenoff,algorithm:minimal"

-- Enhanced file handling for large Salesforce projects
opt.hidden = true -- Allow switching buffers without saving
opt.backup = false -- Disable backup files
opt.writebackup = false -- Disable backup before write
opt.swapfile = false -- Disable swap files
opt.undofile = true -- Enable persistent undo

-- Set up custom filetypes for Salesforce
vim.filetype.add({
  extension = {
    cls = "apex",
    trigger = "apex",
    soql = "soql",
    sosl = "sosl",
  },
  pattern = {
    [".*%.trigger"] = "apex",
    [".*%.cls"] = "apex",
    [".*%-meta%.xml"] = "xml",
  },
})

-- Add this to your init.lua (replace the previous Salesforce keymaps section)

-- Enhanced Salesforce Development Setup
local function setup_enhanced_salesforce()
  -- Check if we're in a Salesforce project
  local handle = io.popen("find . -maxdepth 2 -name 'sfdx-project.json' 2>/dev/null")
  local result = handle:read("*a")
  handle:close()

  if result ~= "" then
    local keymap = vim.keymap
    local opts = { noremap = true, silent = true }

    -- Salesforce CLI commands
    keymap.set("n", "<leader>sdo", ":!sf org open<CR>",
      vim.tbl_extend("force", opts, { desc = "Open Salesforce Org" }))
    keymap.set("n", "<leader>sds", ":!sf project deploy start<CR>",
      vim.tbl_extend("force", opts, { desc = "Deploy to Org" }))
    keymap.set("n", "<leader>sdr", ":!sf project retrieve start<CR>",
      vim.tbl_extend("force", opts, { desc = "Retrieve from Org" }))
    keymap.set("n", "<leader>sdt", ":!sf apex run test<CR>",
      vim.tbl_extend("force", opts, { desc = "Run Apex Tests" }))
    keymap.set("n", "<leader>sdl", ":!sf org list<CR>",
      vim.tbl_extend("force", opts, { desc = "List Orgs" }))
    keymap.set("n", "<leader>sdi", ":!sf org display<CR>",
      vim.tbl_extend("force", opts, { desc = "Show Org Info" }))

    -- File creation commands (like VS Code)
    keymap.set("n", "<leader>sac", ":SfCreateClass<CR>",
      vim.tbl_extend("force", opts, { desc = "Create Apex Class" }))
    keymap.set("n", "<leader>sat", ":SfCreateTestClass<CR>",
      vim.tbl_extend("force", opts, { desc = "Create Apex Test Class" }))
    keymap.set("n", "<leader>satr", ":SfCreateTrigger<CR>",
      vim.tbl_extend("force", opts, { desc = "Create Apex Trigger" }))
    keymap.set("n", "<leader>slc", ":SfCreateLWC<CR>",
      vim.tbl_extend("force", opts, { desc = "Create Lightning Web Component" }))
    keymap.set("n", "<leader>sac", ":SfCreateAura<CR>",
      vim.tbl_extend("force", opts, { desc = "Create Aura Component" }))

    -- Quick navigation for Salesforce project structure
    keymap.set("n", "<leader>sfc", ":e force-app/main/default/classes/<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to Classes" }))
    keymap.set("n", "<leader>sft", ":e force-app/main/default/triggers/<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to Triggers" }))
    keymap.set("n", "<leader>sfl", ":e force-app/main/default/lwc/<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to LWC" }))
    keymap.set("n", "<leader>sfa", ":e force-app/main/default/aura/<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to Aura" }))
    keymap.set("n", "<leader>sfo", ":e force-app/main/default/objects/<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to Objects" }))
    keymap.set("n", "<leader>sfp", ":e force-app/main/default/permissionsets/<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to Permission Sets" }))

    -- Snippet shortcuts (manual trigger for when auto-complete isn't working)
    keymap.set("n", "<leader>ssc", function()
      -- Insert apex class snippet
      local filename = vim.fn.expand("%:t:r")
      local lines = {
        "/**",
        " * @description " .. filename,
        " * @author " .. (vim.fn.getenv("USER") or "Your Name"),
        " * @date " .. os.date("%Y-%m-%d"),
        " */",
        "public class " .. filename .. " {",
        "    ",
        "}"
      }
      vim.api.nvim_put(lines, "l", true, true)
      vim.cmd("normal! 7G$")
    end, vim.tbl_extend("force", opts, { desc = "Insert Apex Class Template" }))

    keymap.set("n", "<leader>ssm", function()
      -- Insert method template
      vim.api.nvim_put({
        "/**",
        " * @description Method description",
        " * @param paramName Parameter description",
        " * @return Return description",
        " */",
        "public static void methodName() {",
        "    ",
        "}"
      }, "l", true, true)
      vim.cmd("normal! 7G$")
    end, vim.tbl_extend("force", opts, { desc = "Insert Apex Method Template" }))

    keymap.set("n", "<leader>sst", function()
      -- Insert test method template
      vim.api.nvim_put({
        "@isTest",
        "static void testMethodName() {",
        "    // Given",
        "    ",
        "    // When",
        "    Test.startTest();",
        "    ",
        "    Test.stopTest();",
        "    ",
        "    // Then",
        "    System.assert(true, 'Test assertion');",
        "}"
      }, "l", true, true)
      vim.cmd("normal! 4G$")
    end, vim.tbl_extend("force", opts, { desc = "Insert Test Method Template" }))

    keymap.set("n", "<leader>ssq", function()
      -- Insert SOQL query template
      vim.api.nvim_put({
        "List<SObject> records = [",
        "    SELECT Id, Name",
        "    FROM SObject",
        "    WHERE Id != null",
        "    LIMIT 100",
        "];"
      }, "l", true, true)
      vim.cmd("normal! 2G$")
    end, vim.tbl_extend("force", opts, { desc = "Insert SOQL Query Template" }))

    -- LWC specific shortcuts
    keymap.set("n", "<leader>slm", function()
      -- Insert LWC method template
      vim.api.nvim_put({
        "methodName() {",
        "    // Method implementation",
        "    ",
        "}"
      }, "l", true, true)
      vim.cmd("normal! 2G$")
    end, vim.tbl_extend("force", opts, { desc = "Insert LWC Method Template" }))

    keymap.set("n", "<leader>slw", function()
      -- Insert LWC wire template
      vim.api.nvim_put({
        "@wire(getRecords, { objectApiName: 'Account' })",
        "wiredRecords({ error, data }) {",
        "    if (data) {",
        "        // Handle data",
        "        ",
        "    } else if (error) {",
        "        // Handle error",
        "        ",
        "    }",
        "}"
      }, "l", true, true)
      vim.cmd("normal! 5G$")
    end, vim.tbl_extend("force", opts, { desc = "Insert LWC Wire Template" }))

    -- Quick SOQL/SOSL execution (requires sf CLI)
    keymap.set("n", "<leader>sqe", function()
      vim.ui.input({ prompt = "Enter SOQL Query: " }, function(query)
        if query then
          vim.cmd("split")
          vim.cmd("terminal sf data query --query \"" .. query .. "\" --json | jq .")
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "Execute SOQL Query" }))

    -- Salesforce documentation shortcuts
    keymap.set("n", "<leader>sdh", function()
      local word = vim.fn.expand("<cword>")
      if word ~= "" then
        -- Try to open specific documentation for the word under cursor
        local urls = {
          ["System"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_system.htm",
          ["Database"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_database.htm",
          ["Test"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_test.htm",
          ["String"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_string.htm",
          ["List"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_list.htm",
          ["Map"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_map.htm",
          ["Set"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_set.htm"
        }

        local url = urls[word] or "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/"
        vim.fn.system("open " .. url)
      else
        vim.fn.system("open https://developer.salesforce.com/docs/")
      end
    end, vim.tbl_extend("force", opts, { desc = "Open Salesforce Documentation" }))

    -- Autocommands for Salesforce development
    local salesforce_group = vim.api.nvim_create_augroup("SalesforceGroup", { clear = true })

    -- Set specific indentation for Salesforce files
    vim.api.nvim_create_autocmd("FileType", {
      group = salesforce_group,
      pattern = "apex",
      callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
        vim.opt_local.commentstring = "// %s"

        -- Add Apex-specific abbreviations
        vim.cmd("iabbrev <buffer> sout System.debug();")
        vim.cmd("iabbrev <buffer> sysd System.debug();")
        vim.cmd("iabbrev <buffer> pubclass public class")
        vim.cmd("iabbrev <buffer> privmethod private static void")
        vim.cmd("iabbrev <buffer> pubmethod public static void")
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

    -- JavaScript/LWC specific settings
    vim.api.nvim_create_autocmd("FileType", {
      group = salesforce_group,
      pattern = {"javascript", "html", "css"},
      callback = function()
        local filepath = vim.fn.expand("%:p")
        if filepath:match("force%-app/main/default/lwc") then
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.expandtab = true

          if vim.bo.filetype == "javascript" then
            -- Add LWC-specific abbreviations
            vim.cmd("iabbrev <buffer> conlog console.log();")
            vim.cmd("iabbrev <buffer> thisevent this.dispatchEvent(new CustomEvent('', { detail: {} }));")
          end
        end
      end,
    })

    -- Auto-save when deploying (optional)
    vim.api.nvim_create_autocmd("User", {
      group = salesforce_group,
      pattern = "SalesforceDeploy",
      callback = function()
        vim.cmd("silent! wall") -- Save all buffers
      end,
    })

    print("🚀 Enhanced Salesforce development environment loaded!")
    print("💡 Use <leader>sa* for file creation, <leader>sd* for deployment, <leader>ss* for snippets")
  end
end

-- Set up enhanced Salesforce environment when Neovim starts
vim.defer_fn(setup_enhanced_salesforce, 100)

-- Auto-commands for better development experience
local general_group = vim.api.nvim_create_augroup("GeneralGroup", { clear = true })

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = general_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 300 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = general_group,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto-resize splits when Vim is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = general_group,
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = general_group,
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Set up custom user commands for Salesforce development
vim.api.nvim_create_user_command("SfDeploy", function()
  vim.cmd("!sf project deploy start")
end, { desc = "Deploy current project to Salesforce org" })

vim.api.nvim_create_user_command("SfRetrieve", function()
  vim.cmd("!sf project retrieve start")
end, { desc = "Retrieve metadata from Salesforce org" })

vim.api.nvim_create_user_command("SfTest", function()
  vim.cmd("!sf apex run test")
end, { desc = "Run all Apex tests" })

vim.api.nvim_create_user_command("SfOpen", function()
  vim.cmd("!sf org open")
end, { desc = "Open Salesforce org in browser" })

-- Display startup message for Salesforce developers
vim.defer_fn(function()
  if vim.fn.isdirectory(".sfdx") == 1 or vim.fn.filereadable("sfdx-project.json") == 1 then
    print("🚀 Salesforce Development Environment Ready!")
    print("Use <leader>s* for Salesforce commands")
  end
end, 100)

-- Add this to your init.lua after the existing content

-- Set up custom filetypes for Salesforce
vim.filetype.add({
  extension = {
    cls = "apex",
    trigger = "apex",
    soql = "soql",
    sosl = "sosl",
  },
  pattern = {
    [".*%.trigger"] = "apex",
    [".*%.cls"] = "apex",
    [".*%-meta%.xml"] = "xml",
  },
})

-- Salesforce-specific keymaps (only if in a Salesforce project)
local function setup_salesforce_keymaps()
  -- Check if we're in a Salesforce project
  local handle = io.popen("find . -maxdepth 2 -name 'sfdx-project.json' 2>/dev/null")
  local result = handle:read("*a")
  handle:close()

  if result ~= "" then
    local keymap = vim.keymap
    local opts = { noremap = true, silent = true }

    -- Salesforce CLI commands (using terminal)
    keymap.set("n", "<leader>sdo", ":!sf org open<CR>", vim.tbl_extend("force", opts, { desc = "Open Salesforce Org" }))
    keymap.set("n", "<leader>sds", ":!sf project deploy start<CR>", vim.tbl_extend("force", opts, { desc = "Deploy to Org" }))
    keymap.set("n", "<leader>sdr", ":!sf project retrieve start<CR>", vim.tbl_extend("force", opts, { desc = "Retrieve from Org" }))
    keymap.set("n", "<leader>sdt", ":!sf apex run test<CR>", vim.tbl_extend("force", opts, { desc = "Run Apex Tests" }))
    keymap.set("n", "<leader>sdl", ":!sf org list<CR>", vim.tbl_extend("force", opts, { desc = "List Orgs" }))
    keymap.set("n", "<leader>sdi", ":!sf org display<CR>", vim.tbl_extend("force", opts, { desc = "Show Org Info" }))

    -- Quick navigation for Salesforce project structure
    keymap.set("n", "<leader>sfc", ":e force-app/main/default/classes/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Classes" }))
    keymap.set("n", "<leader>sft", ":e force-app/main/default/triggers/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Triggers" }))
    keymap.set("n", "<leader>sfl", ":e force-app/main/default/lwc/<CR>", vim.tbl_extend("force", opts, { desc = "Go to LWC" }))
    keymap.set("n", "<leader>sfa", ":e force-app/main/default/aura/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Aura" }))
    keymap.set("n", "<leader>sfo", ":e force-app/main/default/objects/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Objects" }))

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

    -- Autocommands for Salesforce development
    local salesforce_group = vim.api.nvim_create_augroup("SalesforceGroup", { clear = true })

    -- Set specific indentation for Salesforce files
    vim.api.nvim_create_autocmd("FileType", {
      group = salesforce_group,
      pattern = "apex",
      callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
        vim.opt_local.commentstring = "// %s"
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

    print("🚀 Salesforce development environment loaded!")
  end
end

-- Set up Salesforce keymaps when Neovim starts
vim.defer_fn(setup_salesforce_keymaps, 100)
