require("rstof.options")
require("rstof.lazy")

local opt = vim.opt

opt.grepprg = "rg --vimgrep --smart-case --follow"
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 15
opt.diffopt = "internal,filler,closeoff,hiddenoff,algorithm:minimal"
opt.hidden = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

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

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

keymap.set("n", "<S-l>", ":bnext<CR>", opts)
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<leader>bd", ":bdelete<CR>", vim.tbl_extend("force", opts, { desc = "Delete Buffer" }))

keymap.set("n", "<leader>rr", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  vim.tbl_extend("force", opts, { desc = "Replace word under cursor" }))

keymap.set("n", "<leader>w", ":w<CR>", vim.tbl_extend("force", opts, { desc = "Save File" }))
keymap.set("n", "<leader>q", ":q<CR>", vim.tbl_extend("force", opts, { desc = "Quit" }))
keymap.set("n", "<leader>Q", ":qa!<CR>", vim.tbl_extend("force", opts, { desc = "Force Quit All" }))

keymap.set("n", "<leader>n", ":set nu!<CR>", vim.tbl_extend("force", opts, { desc = "Toggle Line Numbers" }))
keymap.set("n", "<leader>h", ":nohlsearch<CR>", vim.tbl_extend("force", opts, { desc = "Clear Search Highlight" }))

keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)
keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

local general_group = vim.api.nvim_create_augroup("GeneralGroup", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = general_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 300 })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = general_group,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = general_group,
  callback = function()
    vim.cmd("wincmd =")
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = general_group,
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Salesforce project detection and setup
local function is_salesforce_project()
  return vim.fn.filereadable("sfdx-project.json") == 1 or vim.fn.isdirectory(".sfdx") == 1
end

-- Only run Salesforce setup if in a Salesforce project
if is_salesforce_project() then
  local function create_apex_class(name)
    local class_dir = vim.fn.getcwd() .. "/force-app/main/default/classes"
    vim.fn.mkdir(class_dir, "p")
    local class_file = class_dir .. "/" .. name .. ".cls"
    local meta_file = class_dir .. "/" .. name .. ".cls-meta.xml"
    local cls_content = string.format([[/**
 * @description %s
 * @author %s
 * @date %s
 */
public class %s {

}]], name, vim.fn.getenv("USER") or "Your Name", os.date("%Y-%m-%d"), name)
    local meta_content = [[<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>60.0</apiVersion>
    <status>Active</status>
</ApexClass>]]
    local cls_file_handle = io.open(class_file, "w")
    if cls_file_handle then
      cls_file_handle:write(cls_content)
      cls_file_handle:close()
    end
    local meta_file_handle = io.open(meta_file, "w")
    if meta_file_handle then
      meta_file_handle:write(meta_content)
      meta_file_handle:close()
    end
    vim.cmd("edit " .. class_file)
    vim.cmd("normal! 6G$")
    print("✅ Created Apex class: " .. name)
  end

  local function create_test_class(name)
    if not name:match("Test$") then
      name = name .. "Test"
    end
    local class_dir = vim.fn.getcwd() .. "/force-app/main/default/classes"
    vim.fn.mkdir(class_dir, "p")
    local class_file = class_dir .. "/" .. name .. ".cls"
    local meta_file = class_dir .. "/" .. name .. ".cls-meta.xml"
    local cls_content = string.format([[/**
 * @description Test class for %s
 * @author %s
 * @date %s
 */
@isTest
public class %s {

    @TestSetup
    static void makeData() {

    }

    @isTest
    static void testMethod() {
        Test.startTest();

        Test.stopTest();

        System.assert(true, 'Test passed');
    }
}]], name:gsub("Test$", ""), vim.fn.getenv("USER") or "Your Name", os.date("%Y-%m-%d"), name)
    local meta_content = [[<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>60.0</apiVersion>
    <status>Active</status>
</ApexClass>]]
    local cls_file_handle = io.open(class_file, "w")
    if cls_file_handle then
      cls_file_handle:write(cls_content)
      cls_file_handle:close()
    end
    local meta_file_handle = io.open(meta_file, "w")
    if meta_file_handle then
      meta_file_handle:write(meta_content)
      meta_file_handle:close()
    end
    vim.cmd("edit " .. class_file)
    vim.cmd("normal! 11G$")
    print("✅ Created Test class: " .. name)
  end

  local function create_lwc_component(name)
    local lwc_dir = vim.fn.getcwd() .. "/force-app/main/default/lwc/" .. name
    vim.fn.mkdir(lwc_dir, "p")
    local class_name = name:gsub("%-(%l)", string.upper):gsub("^%l", string.upper)
    local js_content = string.format([[import { LightningElement } from 'lwc';

export default class %s extends LightningElement {

    connectedCallback() {

    }

}]], class_name)
    local html_content = string.format([[<template>
    <lightning-card title="%s">
        <div class="slds-p-horizontal_small">
            <p>Hello from %s!</p>
        </div>
    </lightning-card>
</template>]], name:gsub("%-", " "):gsub("^%l", string.upper), name)
    local css_content = [[.container {
    padding: 1rem;
}

.slds-card {
    margin: 1rem 0;
}]]
    local meta_content = [[<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>60.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
        <target>lightning__AppPage</target>
        <target>lightning__HomePage</target>
    </targets>
</LightningComponentBundle>]]
    local files = {
      [name .. ".js"] = js_content,
      [name .. ".html"] = html_content,
      [name .. ".css"] = css_content,
      [name .. ".js-meta.xml"] = meta_content
    }
    for filename, content in pairs(files) do
      local file = io.open(lwc_dir .. "/" .. filename, "w")
      if file then
        file:write(content)
        file:close()
      end
    end
    vim.cmd("edit " .. lwc_dir .. "/" .. name .. ".js")
    vim.cmd("normal! 5G$")
    print("✅ Created LWC component: " .. name)
  end

  -- Create user commands
  vim.api.nvim_create_user_command("SfCreateClass", function(cmd_opts)
    local name = cmd_opts.args
    if name == "" then
      vim.ui.input({ prompt = "Apex Class Name: " }, function(input)
        if input and input ~= "" then
          create_apex_class(input)
        end
      end)
    else
      create_apex_class(name)
    end
  end, { nargs = "?", desc = "Create new Apex class" })

  vim.api.nvim_create_user_command("SfCreateTestClass", function(cmd_opts)
    local name = cmd_opts.args
    if name == "" then
      vim.ui.input({ prompt = "Test Class Name: " }, function(input)
        if input and input ~= "" then
          create_test_class(input)
        end
      end)
    else
      create_test_class(name)
    end
  end, { nargs = "?", desc = "Create new Test class" })

  vim.api.nvim_create_user_command("SfCreateLWC", function(cmd_opts)
    local name = cmd_opts.args
    if name == "" then
      vim.ui.input({ prompt = "LWC Name (kebab-case): " }, function(input)
        if input and input ~= "" then
          create_lwc_component(input)
        end
      end)
    else
      create_lwc_component(name)
    end
  end, { nargs = "?", desc = "Create new LWC component" })

  -- Salesforce keymaps
  keymap.set("n", "<leader>sdo", ":!sf org open<CR>", vim.tbl_extend("force", opts, { desc = "Open Salesforce Org" }))
  keymap.set("n", "<leader>sds", ":!sf project deploy start<CR>", vim.tbl_extend("force", opts, { desc = "Deploy to Org" }))
  keymap.set("n", "<leader>sdr", ":!sf project retrieve start<CR>", vim.tbl_extend("force", opts, { desc = "Retrieve from Org" }))
  keymap.set("n", "<leader>sdt", ":!sf apex run test<CR>", vim.tbl_extend("force", opts, { desc = "Run Apex Tests" }))
  keymap.set("n", "<leader>sdl", ":!sf org list<CR>", vim.tbl_extend("force", opts, { desc = "List Orgs" }))
  keymap.set("n", "<leader>sdi", ":!sf org display<CR>", vim.tbl_extend("force", opts, { desc = "Show Org Info" }))

  keymap.set("n", "<leader>sac", ":SfCreateClass<CR>", vim.tbl_extend("force", opts, { desc = "Create Apex Class" }))
  keymap.set("n", "<leader>sat", ":SfCreateTestClass<CR>", vim.tbl_extend("force", opts, { desc = "Create Apex Test Class" }))
  keymap.set("n", "<leader>slc", ":SfCreateLWC<CR>", vim.tbl_extend("force", opts, { desc = "Create Lightning Web Component" }))

  keymap.set("n", "<leader>sfc", ":e force-app/main/default/classes/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Classes" }))
  keymap.set("n", "<leader>sft", ":e force-app/main/default/triggers/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Triggers" }))
  keymap.set("n", "<leader>sfl", ":e force-app/main/default/lwc/<CR>", vim.tbl_extend("force", opts, { desc = "Go to LWC" }))
  keymap.set("n", "<leader>sfa", ":e force-app/main/default/aura/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Aura" }))
  keymap.set("n", "<leader>sfo", ":e force-app/main/default/objects/<CR>", vim.tbl_extend("force", opts, { desc = "Go to Objects" }))

  keymap.set("n", "<leader>sqe", function()
    vim.ui.input({ prompt = "Enter SOQL Query: " }, function(query)
      if query then
        vim.cmd("split")
        vim.cmd("terminal sf data query --query \"" .. query .. "\" --json | jq .")
      end
    end)
  end, vim.tbl_extend("force", opts, { desc = "Execute SOQL Query" }))

  keymap.set("n", "<leader>sdh", function()
    local word = vim.fn.expand("<cword>")
    local urls = {
      ["System"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_system.htm",
      ["Database"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_database.htm",
      ["Test"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_test.htm",
      ["String"] = "https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_string.htm",
    }
    local url = urls[word] or "https://developer.salesforce.com/docs/"
    vim.fn.system("open " .. url)
  end, vim.tbl_extend("force", opts, { desc = "Open Salesforce Documentation" }))

  -- Salesforce autocommands
  local salesforce_group = vim.api.nvim_create_augroup("SalesforceGroup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = salesforce_group,
    pattern = "apex",
    callback = function()
      vim.opt_local.tabstop = 4
      vim.opt_local.shiftwidth = 4
      vim.opt_local.expandtab = true
      vim.opt_local.commentstring = "// %s"
      vim.cmd("iabbrev <buffer> sout System.debug();")
      vim.cmd("iabbrev <buffer> sysd System.debug();")
    end,
  })

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
          vim.cmd("iabbrev <buffer> conlog console.log();")
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.cls",
    callback = function()
      local filename = vim.fn.expand("%:t:r")
      local filepath = vim.fn.expand("%:p")
      if filepath:match("force%-app/main/default/classes") then
        if filename:match("Test$") then
          local lines = {
            "/**",
            " * @description Test class for " .. filename:gsub("Test$", ""),
            " * @author " .. (vim.fn.getenv("USER") or "Your Name"),
            " * @date " .. os.date("%Y-%m-%d"),
            " */",
            "@isTest",
            "public class " .. filename .. " {",
            "    ",
            "    @TestSetup",
            "    static void makeData() {",
            "        ",
            "    }",
            "    ",
            "    @isTest",
            "    static void testMethod() {",
            "        Test.startTest();",
            "        ",
            "        Test.stopTest();",
            "        ",
            "        System.assert(true, 'Test passed');",
            "    }",
            "}"
          }
          vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
          vim.cmd("normal! 11G$")
        else
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
          vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
          vim.cmd("normal! 7G$")
        end
      end
    end,
  })
end

-- Global Salesforce commands (available everywhere)
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
