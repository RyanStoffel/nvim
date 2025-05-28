-- Add this directly to your init.lua instead of creating a separate plugin file

-- Simple Salesforce File Creator Functions
local function create_apex_class(name)
  local current_dir = vim.fn.getcwd()
  local class_dir = current_dir .. "/force-app/main/default/classes"

  -- Create directory if it doesn't exist
  vim.fn.mkdir(class_dir, "p")

  local class_file = class_dir .. "/" .. name .. ".cls"
  local meta_file = class_dir .. "/" .. name .. ".cls-meta.xml"

  -- Class content
  local cls_content = string.format([[/**
 * @description %s
 * @author %s
 * @date %s
 */
public class %s {

}]], name, vim.fn.getenv("USER") or "Your Name", os.date("%Y-%m-%d"), name)

  -- Meta XML content
  local meta_content = [[<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>60.0</apiVersion>
    <status>Active</status>
</ApexClass>]]

  -- Write files
  local cls_file = io.open(class_file, "w")
  if cls_file then
    cls_file:write(cls_content)
    cls_file:close()
  end

  local meta_file_handle = io.open(meta_file, "w")
  if meta_file_handle then
    meta_file_handle:write(meta_content)
    meta_file_handle:close()
  end

  -- Open the class file
  vim.cmd("edit " .. class_file)
  vim.cmd("normal! 6G$")

  print("✅ Created Apex class: " .. name)
end

local function create_test_class(name)
  if not name:match("Test$") then
    name = name .. "Test"
  end

  local current_dir = vim.fn.getcwd()
  local class_dir = current_dir .. "/force-app/main/default/classes"

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
        // Create test data

    }

    @isTest
    static void testMethod() {
        // Given

        // When
        Test.startTest();

        Test.stopTest();

        // Then
        System.assert(true, 'Test passed');
    }
}]], name:gsub("Test$", ""), vim.fn.getenv("USER") or "Your Name", os.date("%Y-%m-%d"), name)

  local meta_content = [[<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>60.0</apiVersion>
    <status>Active</status>
</ApexClass>]]

  local cls_file = io.open(class_file, "w")
  if cls_file then
    cls_file:write(cls_content)
    cls_file:close()
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
  local current_dir = vim.fn.getcwd()
  local lwc_dir = current_dir .. "/force-app/main/default/lwc/" .. name

  vim.fn.mkdir(lwc_dir, "p")

  -- Convert kebab-case to PascalCase
  local class_name = name:gsub("%-(%l)", string.upper):gsub("^%l", string.upper)

  -- JavaScript file
  local js_content = string.format([[import { LightningElement } from 'lwc';

export default class %s extends LightningElement {

    connectedCallback() {
        // Component initialization

    }

}]], class_name)

  -- HTML file
  local html_content = string.format([[<template>
    <lightning-card title="%s">
        <div class="slds-p-horizontal_small">
            <p>Hello from %s!</p>
        </div>
    </lightning-card>
</template>]], name:gsub("%-", " "):gsub("^%l", string.upper), name)

  -- CSS file
  local css_content = [[.container {
    padding: 1rem;
}

.slds-card {
    margin: 1rem 0;
}]]

  -- Meta XML file
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

  -- Write files
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
vim.api.nvim_create_user_command("SfCreateClass", function(opts)
  local name = opts.args
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

vim.api.nvim_create_user_command("SfCreateTestClass", function(opts)
  local name = opts.args
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

vim.api.nvim_create_user_command("SfCreateLWC", function(opts)
  local name = opts.args
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

-- Auto-template for new files (simple version)
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cls",
  callback = function()
    local filename = vim.fn.expand("%:t:r")
    local filepath = vim.fn.expand("%:p")

    if filepath:match("force%-app/main/default/classes") then
      if filename:match("Test$") then
        -- Test class template
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
          "        // Create test data",
          "        ",
          "    }",
          "    ",
          "    @isTest",
          "    static void testMethod() {",
          "        // Given",
          "        ",
          "        // When",
          "        Test.startTest();",
          "        ",
          "        Test.stopTest();",
          "        ",
          "        // Then",
          "        System.assert(true, 'Test passed');",
          "    }",
          "}"
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.cmd("normal! 12G$")
      else
        -- Regular class template
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
